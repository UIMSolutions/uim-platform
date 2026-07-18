/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.databricks.infrastructure.persistence.repositories.delta_tables;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

class MemoryDeltaTableRepository : TenantRepository!(DeltaTable, DeltaTableId), DeltaTableRepository {
  DeltaTable[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(t => t.workspaceId == workspaceId).array;
  }

  DeltaTable[] findByCatalog(TenantId tenantId, string catalogName) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(t => t.catalogName == catalogName).array;
  }

  DeltaTable[] findBySchema(TenantId tenantId, string catalogName, string schemaName) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId)
      .filter!(t => t.catalogName == catalogName && t.schemaName == schemaName)
      .array;
  }

  DeltaTable[] findByType(TenantId tenantId, TableType tableType) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(t => t.tableType == tableType).array;
  }
}
