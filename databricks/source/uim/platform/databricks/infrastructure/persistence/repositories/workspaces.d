/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.databricks.infrastructure.persistence.repositories.workspaces;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class MemoryWorkspaceRepository : TenantRepository!(Workspace, WorkspaceId), WorkspaceRepository {
  Workspace[] findByStatus(TenantId tenantId, WorkspaceStatus status) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(w => w.status == status).array;
  }

  Workspace[] findByRegion(TenantId tenantId, string region) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(w => w.region == region).array;
  }

  Workspace[] findByTier(TenantId tenantId, WorkspaceTier tier) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(w => w.tier == tier).array;
  }
}
