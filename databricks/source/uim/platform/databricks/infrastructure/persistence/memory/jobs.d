module uim.platform.databricks.infrastructure.persistence.memory.jobs;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class MemoryJobRepository : TenantRepository!(Job, JobId), JobRepository {
  Job[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(j => j.workspaceId == workspaceId).array;
  }

  Job[] findByStatus(TenantId tenantId, JobStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(j => j.status == status).array;
  }

  Job[] findByCreator(TenantId tenantId, string creatorId) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(j => j.creatorId == creatorId).array;
  }
}
