/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business enumerations. String valued: the value is the API and storage
/// representation (members ending in "_" are D keywords).
module uim.platform.ai_launchpad.domain.enumerations.launchpad;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

// ── runtimes ─────────────────────────────────────────────────────────────

enum WorkspaceStatus : string {
  active = "active",
  inactive = "inactive"
}

/// Kind of AI runtime behind a connection.
enum ConnectionType : string {
  aiCore = "aiCore", /// SAP AI Core (AI API)
  custom = "custom" /// any runtime implementing the AI API
}

enum ConnectionStatus : string {
  pending = "pending", /// created or changed, not validated yet
  active = "active", /// validated
  error = "error", /// validation failed
  inactive = "inactive" /// switched off
}

enum ResourceGroupStatus : string {
  ready = "ready",
  disabled = "disabled"
}

// ── ML life cycle ────────────────────────────────────────────────────────

/// Life cycle of an execution (training run):
///   pending → running → completed | failed;  pending | running → stopped
enum ExecutionStatus : string {
  pending = "pending",
  running = "running",
  completed = "completed",
  failed = "failed",
  stopped = "stopped"
}

/// Life cycle of a deployment (inference server):
///   pending → running → stopped;  stopped → pending (restart);  pending → dead
enum DeploymentStatus : string {
  pending = "pending",
  running = "running",
  stopped = "stopped",
  dead = "dead"
}

enum ArtifactStatus : string {
  available = "available",
  archived = "archived"
}

// ── generative AI hub ────────────────────────────────────────────────────

enum PromptStatus : string {
  draft = "draft",
  active = "active",
  archived = "archived"
}

// ── launchpad and administration ─────────────────────────────────────────

/// Where a tile leads: an app of the launchpad (route) or an external URL.
enum TileTargetType : string {
  app = "app",
  url = "url"
}

enum LogSeverity : string {
  info = "info",
  warning = "warning",
  error = "error"
}

/// Area of an audit log entry (derived from the event type).
enum LogCategory : string {
  security = "security", /// login, password, token
  administration = "administration", /// users, roles, tiles, log purge
  runtime = "runtime", /// workspaces, connections, resource groups
  lifecycle = "lifecycle", /// scenarios, configurations, executions, deployments, models, datasets
  genai = "genai", /// prompt collections, prompts, playground runs
  system = "system" /// reconciliation, demo content, start
}
