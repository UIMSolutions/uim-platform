module uim.platform.databricks.domain.entities.ml_experiment;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

/// An MLflow experiment for tracking machine-learning runs.
struct MlExperiment {
  mixin TenantEntity!(MlExperimentId);

  WorkspaceId workspaceId;
  string      name;
  string      artifactLocation; // Cloud storage path for artifacts
  string      lifecycleStage;   // active, deleted
  string      ownerId;
  long        creationTime;     // Unix epoch ms
  long        lastUpdateTime;
  string      tags;             // comma-separated key=value pairs
}
