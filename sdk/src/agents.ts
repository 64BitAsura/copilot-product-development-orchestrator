import fs from "node:fs/promises";
import path from "node:path";
import type { AgentId } from "./types.js";

/**
 * Loads the system message for an agent by reading its `.agent.md` file from
 * the `.github/agents/` directory of the repository.
 *
 * The entire file is used as the system message so that the Copilot session
 * inherits the exact persona, constraints, and output format defined for each
 * agent.
 */
export async function loadAgentSystemMessage(
  agentId: AgentId,
  repoRoot: string,
): Promise<string> {
  const filePath = path.join(repoRoot, ".github", "agents", `${agentId}.agent.md`);
  try {
    const content = await fs.readFile(filePath, "utf-8");
    return content;
  } catch {
    // Fallback: return a minimal system message so the pipeline can still run
    // even if the agent file cannot be read.
    return `You are the ${agentId}. Follow your defined responsibilities and produce structured JSON output.`;
  }
}

/**
 * Builds the task prompt sent to each agent.  The prompt references the
 * pipeline directory and the specific input/output files relevant to the agent.
 */
export function buildAgentPrompt(
  agentId: AgentId | "back-tracker-agent-phase-1",
  pipelineDir: string,
  context: Record<string, string>,
): string {
  const inputList = Object.entries(context)
    .map(([label, file]) => `  - ${label}: ${path.join(pipelineDir, file)}`)
    .join("\n");

  const outputFileName = OUTPUT_FILE_FOR_AGENT[agentId];
  const outputPath = path.join(pipelineDir, outputFileName);

  return [
    `You are running as part of the Copilot product-development pipeline.`,
    `Pipeline directory: ${pipelineDir}`,
    ``,
    `Your input files:`,
    inputList,
    ``,
    `Your task: Read the input files listed above, perform your responsibilities as`,
    `defined in your system message, then write your structured JSON output to:`,
    `  ${outputPath}`,
    ``,
    `Write the output file before reporting completion.`,
  ].join("\n");
}

/** Mapping from agent ID (including the phase-1 variant) to its output file. */
const OUTPUT_FILE_FOR_AGENT: Record<AgentId | "back-tracker-agent-phase-1", string> = {
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
  "back-tracker-agent-phase-1": "back-tracker-preliminary.json",
};

/** Input context (label → filename) required by each agent. */
export const AGENT_INPUT_CONTEXT: Record<
  AgentId | "back-tracker-agent-phase-1",
  Record<string, string>
> = {
  "refinement-agent": {},
  "design-agent": { requirements: "requirements.json" },
  "planning-agent": { requirements: "requirements.json", design: "design.json" },
  "performance-agent": { plan: "planning.json" },
  "security-agent": { plan: "planning.json" },
  "coding-agent": {
    plan: "planning.json",
    performance: "performance.json",
    security: "security.json",
  },
  "linting-agent": { coding: "coding.json" },
  "tester-agent": { coding: "coding.json" },
  "documentation-agent": { coding: "coding.json", testing: "testing.json" },
  "build-agent": { coding: "coding.json", testing: "testing.json" },
  "local-deployment-agent": { build: "build.json" },
  "e2e-agent": {
    deployment: "local-deployment.json",
    requirements: "requirements.json",
  },
  "design-review-agent": {
    deployment: "local-deployment.json",
    "design-criteria": "design-ac.json",
  },
  "back-tracker-agent-phase-1": {
    coding: "coding.json",
    requirements: "requirements.json",
  },
  "back-tracker-agent": {
    preliminary: "back-tracker-preliminary.json",
    "e2e-results": "e2e-testing.json",
    "design-review": "design-review.json",
  },
};
