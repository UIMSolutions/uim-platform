module uim.platform.databricks.infrastructure.persistence.memory.delta_tables;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class MemoryDeltaTableRepository : TenantRepository!(DeltaTable, DeltaTableId), DeltaTableRepository {
  DeltaTable[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(t => t.workspaceId == workspaceId).array;
  }

  DeltaTable[] findByCatalog(TenantId tenantId, string catalogName) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(t => t.catalogName == catalogName).array;
  }

  DeltaTable[] findBySchema(TenantId tenantId, string catalogName, string schemaName) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId)
      .filter!(t => t.catalogName == catalogName && t.schemaName == schemaName)
      .array;
  }

  DeltaTable[] findByType(TenantId tenantId, TableType tableType) {
    import std.algorithm : filter;
    import std.array : array;
    return find(tenantId).filter!(t => t.tableType == tableType).array;
  }
}
