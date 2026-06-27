module uim.platform.databricks.domain.ports.repositories.ml_models;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

interface MlModelRepository : TentRepository!(MlModel, MlModelId) {
  MlModel[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  MlModel[] findByStage(TenantId tenantId, ModelStage stage);
  MlModel   findByName(TenantId tenantId, string name);
}
