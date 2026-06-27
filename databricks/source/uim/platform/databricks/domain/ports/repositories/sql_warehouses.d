module uim.platform.databricks.domain.ports.repositories.sql_warehouses;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

interface SqlWarehouseRepository : TentRepository!(SqlWarehouse, SqlWarehouseId) {
  SqlWarehouse[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  SqlWarehouse[] findByState(TenantId tenantId, WarehouseState state);
  SqlWarehouse[] findByType(TenantId tenantId, WarehouseType warehouseType);
  SqlWarehouse[] findRunning(TenantId tenantId);
}
