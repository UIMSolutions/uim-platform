module uim.platform.databricks.domain.entities.sql_warehouse;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

/// A Databricks SQL warehouse (serverless or classic) for analytics queries.
struct SqlWarehouse {
  mixin TenantEntity!(SqlWarehouseId);

  WorkspaceId   workspaceId;
  string        name;
  WarehouseType warehouseType;
  WarehouseSize size;
  WarehouseState state;
  int           numClusters;         // number of concurrent query clusters
  int           autoStopMinutes;     // 0 = never auto-stop
  bool          enablePhoton;        // Photon vectorised execution engine
  bool          enableServerlessCompute;
  string        creatorId;
  long          createdAt;           // Unix epoch ms
  string        jdbcUrl;
  string        odbcParams;
}
