#!/usr/bin/env python3
"""Portable CRAP (Change Risk Analyzer and Predictor) helper for Copilot agents."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def detect_stack(repo_root: Path) -> dict:
    manifests = []
    adapter = "generic"
    package_manager = "none"

    if (repo_root / "package.json").exists():
        adapter = "typescript-node"
        manifests.append("package.json")
        if (repo_root / "pnpm-lock.yaml").exists():
            package_manager = "pnpm"
            manifests.append("pnpm-lock.yaml")
        elif (repo_root / "yarn.lock").exists():
            package_manager = "yarn"
            manifests.append("yarn.lock")
        else:
            package_manager = "npm"
            if (repo_root / "package-lock.json").exists():
                manifests.append("package-lock.json")
    elif (repo_root / "pyproject.toml").exists() or (repo_root / "requirements.txt").exists():
        adapter = "python"
        package_manager = "pip"
        if (repo_root / "pyproject.toml").exists():
            manifests.append("pyproject.toml")
        if (repo_root / "requirements.txt").exists():
            manifests.append("requirements.txt")
    elif (repo_root / "go.mod").exists():
        adapter = "go"
        package_manager = "go"
        manifests.append("go.mod")
    elif (repo_root / "Cargo.toml").exists():
        adapter = "rust"
        package_manager = "cargo"
        manifests.append("Cargo.toml")

    tech_stack_doc = repo_root / "docs/knowledge/tech-stack.md"
    if tech_stack_doc.exists():
        manifests.append("docs/knowledge/tech-stack.md")

    return {
        "adapter": adapter,
        "package_manager": package_manager,
        "manifests": manifests,
    }


def default_command(config_path: Path) -> str:
    return (
        "crap-tool analyze --repo-root . "
        f"--config {config_path.as_posix()} "
        "--planning .copilot/pipeline/planning.json "
        "--coding .copilot/pipeline/coding.json "
        "--testing .copilot/pipeline/testing.json"
    )


def load_json(path: Path) -> dict:
    if not path.exists():
        return {}
    return json.loads(path.read_text())


def setup_config(repo_root: Path, output: Path) -> dict:
    detected = detect_stack(repo_root)
    config = {
        "schema_version": 1,
        "adapter": detected["adapter"],
        "package_manager": detected["package_manager"],
        "manifests": detected["manifests"],
        "commands": {
            "analyze": default_command(output),
        },
        "notes": [
            "Bootstrap should keep this file aligned with the repository tech stack.",
            "The review-agent uses this config to run the CRAP tool before documentation/build stages.",
        ],
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(config, indent=2) + "\n")
    return config


def risk_score(coding: dict, testing: dict) -> tuple[int, list[str], list[str]]:
    score = 0
    reasons: list[str] = []
    high_risk_files: list[str] = []

    files_changed = coding.get("files_changed", [])
    file_count = len(files_changed)
    score += min(file_count * 4, 24)
    if file_count:
        reasons.append(f"{file_count} file(s) changed")

    if coding.get("database_changes"):
        score += 15
        reasons.append("database changes present")

    api_changes = coding.get("api_changes", {})
    if api_changes.get("new_endpoints") or api_changes.get("modified_endpoints"):
        score += 12
        reasons.append("API surface changed")

    testing_result = testing.get("overall_result")
    if testing_result and testing_result != "PASSED":
        score += 30
        reasons.append("tests not fully passing")

    if testing and testing.get("coverage_threshold_met") is False:
        score += 20
        reasons.append("coverage threshold missed")

    for changed in files_changed:
        path = changed.get("path", "")
        lowered = path.lower()
        if any(token in lowered for token in ("auth", "permission", "policy", "migration", "schema", "workflow", "docker")):
            high_risk_files.append(path)

    if high_risk_files:
        score += min(len(high_risk_files) * 5, 20)
        reasons.append("high-risk infrastructure/auth/schema files changed")

    return min(score, 100), reasons, high_risk_files


def analyze(repo_root: Path, config_path: Path, planning_path: Path, coding_path: Path, testing_path: Path) -> dict:
    config = load_json(config_path) if config_path.exists() else setup_config(repo_root, config_path)
    coding = load_json(coding_path)
    testing = load_json(testing_path)
    _ = load_json(planning_path)

    score, reasons, high_risk_files = risk_score(coding, testing)
    if score >= 75:
        risk_level = "critical"
    elif score >= 50:
        risk_level = "high"
    elif score >= 25:
        risk_level = "medium"
    else:
        risk_level = "low"

    return {
        "adapter": config.get("adapter", "generic"),
        "package_manager": config.get("package_manager", "none"),
        "score": score,
        "risk_level": risk_level,
        "signals": reasons,
        "high_risk_files": high_risk_files,
        "config_path": config_path.as_posix(),
    }


def main() -> int:
    parser = argparse.ArgumentParser(prog="crap-tool")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("version")

    setup_parser = subparsers.add_parser("setup")
    setup_parser.add_argument("--repo-root", default=".")
    setup_parser.add_argument("--output", default=".copilot/crap/config.json")

    analyze_parser = subparsers.add_parser("analyze")
    analyze_parser.add_argument("--repo-root", default=".")
    analyze_parser.add_argument("--config", default=".copilot/crap/config.json")
    analyze_parser.add_argument("--planning", default=".copilot/pipeline/planning.json")
    analyze_parser.add_argument("--coding", default=".copilot/pipeline/coding.json")
    analyze_parser.add_argument("--testing", default=".copilot/pipeline/testing.json")

    args = parser.parse_args()

    if args.command == "version":
        print("crap-tool 0.1.0")
        return 0

    if args.command == "setup":
        config = setup_config(Path(args.repo_root), Path(args.output))
        print(json.dumps(config, indent=2))
        return 0

    if args.command == "analyze":
        result = analyze(
            Path(args.repo_root),
            Path(args.config),
            Path(args.planning),
            Path(args.coding),
            Path(args.testing),
        )
        print(json.dumps(result, indent=2))
        return 0

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
