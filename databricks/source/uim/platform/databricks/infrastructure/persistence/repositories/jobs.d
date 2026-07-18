/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.databricks.infrastructure.persistence.repositories.jobs;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class MemoryJobRepository : TenantRepository!(Job, JobId), JobRepository {
  Job[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(j => j.workspaceId == workspaceId).array;
  }

  Job[] findByStatus(TenantId tenantId, JobStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(j => j.status == status).array;
  }

  Job[] findByCreator(TenantId tenantId, string creatorId) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(j => j.creatorId == creatorId).array;
  }
}
