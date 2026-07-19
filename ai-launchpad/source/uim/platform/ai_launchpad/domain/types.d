/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.types;

import uim.platform.ai_launchpad;
mixin(ShowModule!());

@safe:

/// Strongly-typed identifier for an Artifact.
struct ArtifactId {
  mixin(IdTemplate);
}
/// 
unittest {
  auto id = ArtifactId("artifact-123");
  assert(id.value == "artifact-123");
  assert(id.toString() == "artifact-123");
  assert(id == ArtifactId("artifact-123"));
}

/// Strongly-typed identifier for a Workspace.
struct WorkspaceId {
  mixin(IdTemplate);
}
/// 
unittest {
  auto id = WorkspaceId("workspace-123");
  assert(id.value == "workspace-123");
  assert(id.toString() == "workspace-123");
  assert(id == WorkspaceId("workspace-123"));
}

/// Strongly-typed identifier for a Scenario.
struct ScenarioId {
  mixin(IdTemplate);
}
/// 
unittest {
  auto id = ScenarioId("scenario-123");
  assert(id.value == "scenario-123");
  assert(id.toString() == "scenario-123");
  assert(id == ScenarioId("scenario-123"));
}

/// Strongly-typed identifier for a Configuration.
struct ConfigurationId {
  mixin(IdTemplate);
}
/// 
unittest {
  auto id = ConfigurationId("configuration-123");
  assert(id.value == "configuration-123");
  assert(id.toString() == "configuration-123");
  assert(id == ConfigurationId("configuration-123"));
}

/// Strongly-typed identifier for an Execution.
struct ExecutionId {
  mixin(IdTemplate);
}
/// 
unittest {
  auto id = ExecutionId("execution-123");
  assert(id.value == "execution-123");
  assert(id.toString() == "execution-123");
  assert(id == ExecutionId("execution-123"));
}

/// Strongly-typed identifier for a Deployment.
struct DeploymentId {
  mixin(IdTemplate);
}
/// 
unittest {
  auto id = DeploymentId("deployment-123");
  assert(id.value == "deployment-123");
  assert(id.toString() == "deployment-123");
  assert(id == DeploymentId("deployment-123"));
}

/// Strongly-typed identifier for a Resource Group.
struct ResourceGroupId {
  mixin(IdTemplate);
}
  /// 
  unittest {
    auto id = ResourceGroupId("resource-group-123");
    assert(id.value == "resource-group-123");
    assert(id.toString() == "resource-group-123");
    assert(id == ResourceGroupId("resource-group-123"));
  }

  /// Strongly-typed identifier for a Model.
  struct ModelId {
    mixin(IdTemplate);
  }
  /// 
  unittest {
    auto id = ModelId("model-123");
    assert(id.value == "model-123");
    assert(id.toString() == "model-123");
    assert(id == ModelId("model-123"));
  }

  /// Strongly-typed identifier for a Dataset.
  struct DatasetId {
    mixin(IdTemplate);
  }
  /// 
  unittest {
    auto id = DatasetId("dataset-123");
    assert(id.value == "dataset-123");
    assert(id.toString() == "dataset-123");
    assert(id == DatasetId("dataset-123"));
  }

  /// Strongly-typed identifier for a Prompt.
  struct PromptId {
    mixin(IdTemplate);
  }
  /// 
  unittest {
    auto id = PromptId("prompt-123");
    assert(id.value == "prompt-123");
    assert(id.toString() == "prompt-123");
    assert(id == PromptId("prompt-123"));
  }

  /// Strongly-typed identifier for a Prompt Collection.
  struct PromptCollectionId {
    mixin(IdTemplate);
  }
  /// 
  unittest {
    auto id = PromptCollectionId("prompt-collection-123");
    assert(id.value == "prompt-collection-123");
    assert(id.toString() == "prompt-collection-123");
    assert(id == PromptCollectionId("prompt-collection-123"));
  }

  /// Strongly-typed identifier for a Usage Statistic.
  struct UsageStatisticId {
    mixin(IdTemplate);
  }
  /// 
  unittest {
    auto id = UsageStatisticId("usage-statistic-123");
    assert(id.value == "usage-statistic-123");
    assert(id.toString() == "usage-statistic-123");
    assert(id == UsageStatisticId("usage-statistic-123"));
  }
