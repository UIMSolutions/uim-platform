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
  string        jdbcUrl;
  string        odbcParams;

    Json toJson() const { 
        auto j = entityToJson()
        .set("workspaceId", workspaceId)
        .set("name", name)
        .set("warehouseType", warehouseType)
        .set("size", size)
        .set("state", state)
        .set("numClusters", numClusters)
        .set("autoStopMinutes", autoStopMinutes)
        .set("enablePhoton", enablePhoton)
        .set("enableServerlessCompute", enableServerlessCompute)
        .set("creatorId", creatorId)
        .set("jdbcUrl", jdbcUrl)
        .set("odbcParams", odbcParams);

    return j;
  }

}
