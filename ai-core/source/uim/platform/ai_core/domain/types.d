/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.types;

import uim.platform.ai_core;
mixin(ShowModule!()); 

@safe:

/// Strongly-typed identifier for a Scenario.
struct ScenarioId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for an Executable.
struct ExecutableId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a Configuration.
struct ConfigurationId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for an Execution.
struct ExecutionId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a Deployment.
struct DeploymentId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for an Artifact.
struct ArtifactId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a Resource Group.
struct ResourceGroupId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a Metric.
struct MetricId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a Docker Registry Secret.
struct DockerRegistrySecretId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for an Object Store Secret.
struct ObjectStoreSecretId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a Schedule.
struct ScheduleId {
    mixin(IdTemplate);
}
