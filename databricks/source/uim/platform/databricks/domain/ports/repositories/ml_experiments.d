module uim.platform.databricks.domain.ports.repositories.ml_experiments;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

interface MlExperimentRepository : TenantRepository!(MlExperiment, MlExperimentId) {
  MlExperiment[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  MlExperiment[] findActive(TenantId tenantId);
  MlExperiment   findByName(TenantId tenantId, string name);
}
