module uim.platform.databricks.domain.ports.repositories.jobs;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

interface JobRepository : TentRepository!(Job, JobId) {
  Job[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  Job[] findByStatus(TenantId tenantId, JobStatus status);
  Job[] findByCreator(TenantId tenantId, string creatorId);
}
