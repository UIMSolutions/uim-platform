module uim.platform.databricks.infrastructure.persistence.memory.sql_warehouses;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class MemorySqlWarehouseRepository : TenantRepository!(SqlWarehouse, SqlWarehouseId), SqlWarehouseRepository {
  SqlWarehouse[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(w => w.workspaceId == workspaceId).array;
  }

  SqlWarehouse[] findByState(TenantId tenantId, WarehouseState state) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(w => w.state == state).array;
  }

  SqlWarehouse[] findByType(TenantId tenantId, WarehouseType warehouseType) {
    import std.algorithm : filter;
    import std.array : array;
    return findByTenant(tenantId).filter!(w => w.warehouseType == warehouseType).array;
  }

  SqlWarehouse[] findRunning(TenantId tenantId) {
    return findByState(tenantId, WarehouseState.running);
  }
}
