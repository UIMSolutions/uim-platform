/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.types;

// ID aliases
struct ConnectionId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct WorkspaceId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct ScenarioId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct ConfigurationId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct ExecutionId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct DeploymentId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct ModelId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct DatasetId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct PromptId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct PromptCollectionId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct ResourceGroupId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct StatisticsId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct TenantId {
      string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

// Connection to an AI runtime instance
enum ConnectionStatus { active, inactive, error, pending }
enum ConnectionType { ai_core, custom }

// Execution lifecycle
enum ExecutionStatus { pending, running, completed, failed, stopped, dead, unknown }

// Deployment lifecycle
enum DeploymentStatus { pending, running, stopped, dead, unknown }

// Model tracking
enum ModelStatus { available, archived, deprecated_ }

// Dataset tracking
enum DatasetStatus { available, processing, error, archived }

// Workspace
enum WorkspaceStatus { active, inactive }

// GenAI Hub prompt management
enum PromptRole { system, user, assistant }
enum PromptStatus { draft, active, archived }

// Artifact classification
enum ArtifactKind { model, dataset, resultset, other }

// Target status for lifecycle operations
enum TargetStatus { running, stopped, deleted_, completed }

// Usage statistics
enum StatisticsPeriod { daily, weekly, monthly }
