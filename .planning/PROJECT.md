# Project: Code-to-Docs Skill Hardening (Local-Only)

## Vision
Improve and secure this skill project so it can run locally with strong protections for analyzed source code and generated content, minimizing data exposure risks while preserving developer productivity.

## Problem
The project currently has codebase mapping artifacts but no initialized project-level planning contract. Security and privacy expectations for local usage are not yet encoded as formal requirements, roadmap phases, and workflow defaults.

## Goals
- Enforce local-only workflows by default.
- Protect analyzed code/content at rest and in transit.
- Reduce accidental exfiltration through tooling, logs, and integrations.
- Maintain practical usability for day-to-day development.
- Keep all assistant-facing communication in English.

## Non-Goals
- Building a cloud-hosted multi-tenant SaaS.
- Supporting remote telemetry collection by default.
- Adding broad feature scope unrelated to security, privacy, or reliability.

## Users
- Primary: local developer/operator maintaining this repository.
- Secondary: trusted collaborators on the same machine/network boundary.

## Success Criteria
- A documented and executable roadmap exists with security-first phases.
- Local-only constraints are explicit in requirements and operational rules.
- Data handling policies cover source code, docs, logs, caches, and exports.
- Baseline verification and threat checks are integrated into workflows.
- A **single local command** (`./scripts/validate-security.sh`) plus **regression probe** (`./scripts/security-regression.sh`) and **checklist** (`docs/security/validation-checklist.md`) support repeatable hardening validation (Milestone 1 / Phase 4).

## Constraints
- Operate primarily in local environment.
- Preserve existing repository behavior unless a security hardening change is intentional.
- Prefer reversible and auditable changes.
- Communication language for assistant outputs: English.

## Inputs
- User brief: "improve and secure skill/project for local use only, protecting analyzed code/content."
- Existing codebase map in `.planning/codebase/`.

## Risks
- Security controls that are too strict may reduce usability.
- Hidden data egress paths may exist across tools and plugins.
- Local machine compromise remains an out-of-scope platform risk but should be mitigated where practical.
