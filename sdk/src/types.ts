/** Pipeline execution lanes. */
export type Lane = "full" | "backend" | "hotfix" | "config";

/** Top-level pipeline input options. */
export interface PipelineOptions {
  /** GitHub issue number being processed. */
  issueNumber: number;
  /** Pipeline lane — determines which agents run. */
  lane: Lane;
  /** Path to the repository root (defaults to cwd). */
  repoRoot?: string;
  /** GitHub token used to authenticate the Copilot SDK client. */
  githubToken?: string;
  /** Model to use for every agent session. */
  model?: string;
}

/** Result produced by a single agent session. */
export interface AgentResult {
  /** Agent identifier (matches the stem of its `.agent.md` file). */
  agentId: string;
  /** Path to the JSON output file written by the agent. */
  outputFile: string;
  /** Raw content of the output file (parsed JSON). */
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  output: Record<string, unknown>;
}

/** Describes the shape of the `state.json` pipeline file. */
export interface PipelineState {
  sessionId: string;
  issueNumber: number;
  lane: Lane;
  stage: string;
  status: "in_progress" | "completed" | "failed";
  startedAt: string;
  updatedAt: string;
}

/** Names of every agent in the pipeline (matches `.agent.md` file stems). */
export const AGENT_IDS = [
  "refinement-agent",
  "design-agent",
  "planning-agent",
  "performance-agent",
  "security-agent",
  "coding-agent",
  "linting-agent",
  "tester-agent",
  "documentation-agent",
  "build-agent",
  "local-deployment-agent",
  "e2e-agent",
  "design-review-agent",
  "back-tracker-agent",
] as const;

export type AgentId = (typeof AGENT_IDS)[number];

/** Maps each agent to the pipeline JSON file it produces. */
export const AGENT_OUTPUT_FILES: Record<AgentId | "back-tracker-agent-phase-1", string> = {
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
