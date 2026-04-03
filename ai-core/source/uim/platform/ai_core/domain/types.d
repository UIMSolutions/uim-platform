/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.types;

// ID aliases
alias ScenarioId = string;
alias ExecutableId = string;
alias ConfigurationId = string;
alias ExecutionId = string;
alias DeploymentId = string;
alias ArtifactId = string;
alias ResourceGroupId = string;
alias MetricId = string;
alias TenantId = string;
alias DockerRegistrySecretId = string;
alias ObjectStoreSecretId = string;

// Executable types: workflow (batch), serving (inference)
enum ExecutableType {
  workflow,
  serving,
}

// Execution lifecycle states
enum ExecutionStatus {
  pending,
  running,
  completed,
  failed,
  stopped,
  dead,
  unknown,
}

// Deployment lifecycle states
enum DeploymentStatus {
  pending,
  running,
  stopped,
  dead,
  unknown,
}

// Artifact categories
enum ArtifactKind {
  model,
  dataset,
  resultset,
  other,
}

// Target state for PATCH operations
enum TargetStatus {
  running,
  stopped,
  deleted_,
  completed,
}

// Metric value types
enum MetricValueType {
  float_,
  int_,
  string_,
}

// Log severity levels
enum LogSeverity {
  info,
  warn,
  error,
}

// Schedule status
enum ScheduleStatus {
  active,
  inactive,
}
