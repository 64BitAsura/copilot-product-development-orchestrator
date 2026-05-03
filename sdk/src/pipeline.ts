/**
 * pipeline.ts — Parallel pipeline orchestrator using the GitHub Copilot SDK
 *
 * This module implements the full Copilot product-development pipeline by
 * creating one CopilotSession per agent and running independent stages in
 * parallel with Promise.all().
 *
 * Pipeline DAG:
 *
 *   refinement → [design?] → planning
 *                                 │
 *             ┌───────────────────┤ (parallel)
 *             ▼                   ▼
 *        performance          security
 *             └───────────────────┤
 *                                 ▼
 *                              coding → linting → testing
 *                                                    │
 *                           ┌───────────────────────┤ (parallel)
 *                           ▼                        ▼
 *                     documentation               build
 *                                                    │
 *                                          local-deployment
 *                                                    │
 *                ┌──────────────────────────────────┤ (parallel)
 *                ▼                ▼                  ▼
 *               e2e        design-review?   back-tracker-phase-1
 *                └──────────────────────────────────┤
 *                                                    ▼
 *                                         back-tracker-phase-2
 *                                                    │
 *                                              pull-request
 */

import fs from "node:fs/promises";
import path from "node:path";
import { randomUUID } from "node:crypto";
import { CopilotClient, approveAll } from "@github/copilot-sdk";
import type { AgentId, PipelineOptions, AgentResult, PipelineState } from "./types.js";
import { loadAgentSystemMessage, buildAgentPrompt, AGENT_INPUT_CONTEXT } from "./agents.js";

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const DEFAULT_MODEL = "gpt-5";
const PIPELINE_SUBDIR = ".copilot/pipeline";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Write (or overwrite) a JSON file under the pipeline directory. */
async function writePipelineFile(
  pipelineDir: string,
  filename: string,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data: Record<string, unknown>,
): Promise<void> {
  await fs.mkdir(pipelineDir, { recursive: true });
  await fs.writeFile(path.join(pipelineDir, filename), JSON.stringify(data, null, 2), "utf-8");
}

/** Read and parse a JSON file from the pipeline directory. */
async function readPipelineFile(
  pipelineDir: string,
  filename: string,
): Promise<Record<string, unknown>> {
  const content = await fs.readFile(path.join(pipelineDir, filename), "utf-8");
  return JSON.parse(content) as Record<string, unknown>;
}

/** Update the pipeline state.json at the end of each stage. */
async function updateState(
  pipelineDir: string,
  state: PipelineState,
  stage: string,
  status: PipelineState["status"],
): Promise<void> {
  const updated: PipelineState = {
    ...state,
    stage,
    status,
    updatedAt: new Date().toISOString(),
  };
  await writePipelineFile(pipelineDir, "state.json", updated as unknown as Record<string, unknown>);
}

// ---------------------------------------------------------------------------
// Core: run a single agent session
// ---------------------------------------------------------------------------

/**
 * Creates a Copilot session for the given agent, sends the task prompt, waits
 * for the session to become idle, then reads and returns the output JSON file.
 */
async function runAgent(
  client: CopilotClient,
  agentId: AgentId | "back-tracker-agent-phase-1",
  pipelineDir: string,
  repoRoot: string,
  model: string,
): Promise<AgentResult> {
  // Map the phase-1 variant back to the real agent file name for system message loading.
  const fileAgentId: AgentId =
    agentId === "back-tracker-agent-phase-1" ? "back-tracker-agent" : agentId;

  const systemMessage = await loadAgentSystemMessage(fileAgentId, repoRoot);
  const inputContext = AGENT_INPUT_CONTEXT[agentId];
  const prompt = buildAgentPrompt(agentId, pipelineDir, inputContext);

  console.log(`[${agentId}] Starting session…`);

  await using session = await client.createSession({
    sessionId: `${agentId}-${randomUUID()}`,
    model,
    onPermissionRequest: approveAll,
    systemMessage: { content: systemMessage },
  });

  const response = await session.sendAndWait({ prompt });

  if (response) {
    console.log(`[${agentId}] Completed: ${response.data.content.slice(0, 120)}…`);
  }

  // Determine which output file name to read (phase-1 uses a different file).
  const outputFileName =
    agentId === "back-tracker-agent-phase-1"
      ? "back-tracker-preliminary.json"
      : agentId === "back-tracker-agent"
        ? "back-tracker.json"
        : OUTPUT_FILE_BY_AGENT[agentId];

  let output: Record<string, unknown> = {};
  try {
    output = await readPipelineFile(pipelineDir, outputFileName);
  } catch {
    console.warn(`[${agentId}] Warning: output file '${outputFileName}' not found after session completed.`);
  }

  return {
    agentId,
    outputFile: path.join(pipelineDir, outputFileName),
    output,
  };
}

/** Output filenames indexed by agent ID (non-phase-1 only). */
const OUTPUT_FILE_BY_AGENT: Record<AgentId, string> = {
  "refinement-agent": "requirements.json",
  "design-agent": "design.json",
  "planning-agent": "planning.json",
  "performance-agent": "performance.json",
  "security-agent": "security.json",
  "coding-agent": "coding.json",
  "linting-agent": "linting.json",
  "tester-agent": "testing.json",
  "documentation-agent": "documentation.json",
  "build-agent": "build.json",
  "local-deployment-agent": "local-deployment.json",
  "e2e-agent": "e2e-testing.json",
  "design-review-agent": "design-review.json",
  "back-tracker-agent": "back-tracker.json",
};

// ---------------------------------------------------------------------------
// Pipeline runner
// ---------------------------------------------------------------------------

/**
 * Runs the full product-development pipeline.
 *
 * Stages that are independent of each other are dispatched with Promise.all()
 * so they execute in parallel on separate Copilot sessions:
 *
 *   - Stage 4:  performance + security        (parallel)
 *   - Stage 8:  documentation + build         (parallel)
 *   - Stage 10: e2e + design-review + bt-ph1  (parallel)
 */
export async function runPipeline(options: PipelineOptions): Promise<void> {
  const {
    issueNumber,
    lane,
    repoRoot = process.cwd(),
    githubToken,
    model = DEFAULT_MODEL,
  } = options;

  const pipelineDir = path.join(repoRoot, PIPELINE_SUBDIR);
  const sessionId = randomUUID();

  console.log(`\n╔══════════════════════════════════════════════════════╗`);
  console.log(`║  Copilot Product-Development Pipeline                ║`);
  console.log(`║  Issue: #${String(issueNumber).padEnd(43)}║`);
  console.log(`║  Lane:  ${lane.padEnd(44)}║`);
  console.log(`╚══════════════════════════════════════════════════════╝\n`);

  // Initialise the Copilot SDK client.
  const client = new CopilotClient({ gitHubToken: githubToken });
  await client.start();

  const state: PipelineState = {
    sessionId,
    issueNumber,
    lane,
    stage: "init",
    status: "in_progress",
    startedAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  await writePipelineFile(pipelineDir, "state.json", state as unknown as Record<string, unknown>);

  try {
    // ── Stage 1: Refinement ──────────────────────────────────────────────────
    await updateState(pipelineDir, state, "refinement", "in_progress");
    console.log("\n▶  Stage 1 · Refinement");
    await runAgent(client, "refinement-agent", pipelineDir, repoRoot, model);

    // ── Stage 2: Design (full lane only) ─────────────────────────────────────
    if (lane === "full") {
      await updateState(pipelineDir, state, "design", "in_progress");
      console.log("\n▶  Stage 2 · Design");
      await runAgent(client, "design-agent", pipelineDir, repoRoot, model);
    } else {
      console.log("\n⏭  Stage 2 · Design — skipped (non-full lane)");
    }

    // ── Stage 3: Planning ─────────────────────────────────────────────────────
    await updateState(pipelineDir, state, "planning", "in_progress");
    console.log("\n▶  Stage 3 · Planning");
    await runAgent(client, "planning-agent", pipelineDir, repoRoot, model);

    // ── Stage 4 (parallel): Performance + Security ───────────────────────────
    await updateState(pipelineDir, state, "performance+security", "in_progress");
    console.log("\n▶  Stage 4 · Performance + Security  (parallel)");
    await Promise.all([
      runAgent(client, "performance-agent", pipelineDir, repoRoot, model),
      runAgent(client, "security-agent", pipelineDir, repoRoot, model),
    ]);

    // ── Stage 5: Coding ───────────────────────────────────────────────────────
    await updateState(pipelineDir, state, "coding", "in_progress");
    console.log("\n▶  Stage 5 · Coding");
    await runAgent(client, "coding-agent", pipelineDir, repoRoot, model);

    // ── Stage 6: Linting ──────────────────────────────────────────────────────
    await updateState(pipelineDir, state, "linting", "in_progress");
    console.log("\n▶  Stage 6 · Linting");
    await runAgent(client, "linting-agent", pipelineDir, repoRoot, model);

    // ── Stage 7: Testing ──────────────────────────────────────────────────────
    await updateState(pipelineDir, state, "testing", "in_progress");
    console.log("\n▶  Stage 7 · Testing");
    await runAgent(client, "tester-agent", pipelineDir, repoRoot, model);

    // ── Stage 8 (parallel): Documentation + Build ────────────────────────────
    await updateState(pipelineDir, state, "documentation+build", "in_progress");
    console.log("\n▶  Stage 8 · Documentation + Build  (parallel)");
    await Promise.all([
      runAgent(client, "documentation-agent", pipelineDir, repoRoot, model),
      runAgent(client, "build-agent", pipelineDir, repoRoot, model),
    ]);

    // ── Stage 9: Local Deployment ─────────────────────────────────────────────
    await updateState(pipelineDir, state, "local-deployment", "in_progress");
    console.log("\n▶  Stage 9 · Local Deployment");
    await runAgent(client, "local-deployment-agent", pipelineDir, repoRoot, model);

    // ── Stage 10 (parallel): E2E + Design Review? + Back Tracker Phase 1 ─────
    await updateState(pipelineDir, state, "e2e+review+bt-phase-1", "in_progress");

    const parallelStage10: Array<Promise<AgentResult>> = [
      runAgent(client, "e2e-agent", pipelineDir, repoRoot, model),
      runAgent(client, "back-tracker-agent-phase-1", pipelineDir, repoRoot, model),
    ];

    if (lane === "full") {
      console.log("\n▶  Stage 10 · E2E + Design Review + Back Tracker Phase 1  (parallel)");
      parallelStage10.push(
        runAgent(client, "design-review-agent", pipelineDir, repoRoot, model),
      );
    } else {
      console.log("\n▶  Stage 10 · E2E + Back Tracker Phase 1  (parallel)");
    }

    await Promise.all(parallelStage10);

    // ── Stage 11: Back Tracker Phase 2 ───────────────────────────────────────
    await updateState(pipelineDir, state, "back-tracker-phase-2", "in_progress");
    console.log("\n▶  Stage 11 · Back Tracker Phase 2");
    const btResult = await runAgent(client, "back-tracker-agent", pipelineDir, repoRoot, model);

    const verdict = (btResult.output as { verdict?: string }).verdict ?? "approved";
    if (verdict !== "approved") {
      throw new Error(`Back Tracker verdict: '${verdict}' — pipeline blocked before PR creation.`);
    }

    // ── Stage 12: Done ────────────────────────────────────────────────────────
    await updateState(pipelineDir, state, "completed", "completed");
    console.log("\n✅  Pipeline completed — open a pull request for issue #" + issueNumber);
  } catch (error) {
    await updateState(pipelineDir, state, state.stage, "failed").catch(() => undefined);
    throw error;
  } finally {
    await client.stop();
  }
}

// ---------------------------------------------------------------------------
// CLI entry point
// ---------------------------------------------------------------------------

if (process.argv[1]?.endsWith("pipeline.ts") || process.argv[1]?.endsWith("pipeline.js")) {
  const issueArg = process.argv[2];
  const laneArg = (process.argv[3] ?? "full") as PipelineOptions["lane"];

  if (!issueArg || Number.isNaN(Number(issueArg))) {
    console.error("Usage: pipeline.ts <issue-number> [lane]");
    console.error("  lane: full | backend | hotfix | config  (default: full)");
    process.exit(1);
  }

  runPipeline({
    issueNumber: Number(issueArg),
    lane: laneArg,
    repoRoot: process.env["REPO_ROOT"] ?? process.cwd(),
    githubToken: process.env["GITHUB_TOKEN"],
    model: process.env["COPILOT_MODEL"] ?? DEFAULT_MODEL,
  }).catch((err: unknown) => {
    console.error("Pipeline failed:", err);
    process.exit(1);
  });
}
