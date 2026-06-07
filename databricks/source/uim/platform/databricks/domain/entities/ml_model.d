module uim.platform.databricks.domain.entities.ml_model;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

/// A registered ML model in the MLflow Model Registry.
struct MlModel {
  mixin TenantEntity!(MlModelId);

  WorkspaceId workspaceId;
  string      name;
  string      description;
  ModelStage  latestStage;
  string      latestVersion;
  string      ownerId;
  long        creationTime;   // Unix epoch ms
  long        lastUpdatedAt;
  string      tags;           // comma-separated key=value pairs
  string      source;         // Run artifact URI that produced this model
}
