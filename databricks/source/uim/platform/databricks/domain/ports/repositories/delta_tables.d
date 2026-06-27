module uim.platform.databricks.domain.ports.repositories.delta_tables;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

interface DeltaTableRepository : TenantRepository!(DeltaTable, DeltaTableId) {
  DeltaTable[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  DeltaTable[] findByCatalog(TenantId tenantId, string catalogName);
  DeltaTable[] findBySchema(TenantId tenantId, string catalogName, string schemaName);
  DeltaTable[] findByType(TenantId tenantId, TableType tableType);
}
