/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.databricks.application.usecases.manage_sql_warehouses;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

class ManageSqlWarehousesUseCase {
private:
  SqlWarehouseRepository _repo;

public:
  this(SqlWarehouseRepository repo) { _repo = repo; }

  UseCaseResult!SqlWarehouse create(CreateSqlWarehouseRequest r) {
    auto w = SqlWarehouse();
    w.id                      = r.id;
    w.tenantId                = r.tenantId;
    w.workspaceId             = r.workspaceId;
    w.name                    = r.name;
    w.warehouseType           = r.warehouseType;
    w.size                    = r.size;
    w.state                   = WarehouseState.starting;
    w.numClusters             = r.numClusters > 0 ? r.numClusters : 1;
    w.autoStopMinutes         = r.autoStopMinutes;
    w.enablePhoton            = r.enablePhoton;
    w.enableServerlessCompute = r.enableServerlessCompute;
    w.creatorId               = r.creatorId;
    import std.datetime : Clock;
    w.createdAt = Clock.currTime().toUnixTime() * 1000;
    _repo.save(w);
    return UseCaseResult!SqlWarehouse(true, "SQL warehouse created", w);
  }

  UseCaseResult!(SqlWarehouse[]) list(TenantId tenantId) {
    return UseCaseResult!(SqlWarehouse[])(true, "", _repo.find(tenantId));
  }

  UseCaseResult!SqlWarehouse get(TenantId tenantId, SqlWarehouseId id) {
    auto w = _repo.find(tenantId, id);
    if (w.isNull)
      return UseCaseResult!SqlWarehouse(false, "SQL warehouse not found", SqlWarehouse.init);
    return UseCaseResult!SqlWarehouse(true, "", w);
  }

  UseCaseResult!SqlWarehouse update(UpdateSqlWarehouseRequest r) {
    auto w = _repo.find(r.tenantId, r.id);
    if (w.isNull)
      return UseCaseResult!SqlWarehouse(false, "SQL warehouse not found", SqlWarehouse.init);
    if (r.name.length > 0) w.name    = r.name;
    w.size             = r.size;
    w.numClusters      = r.numClusters;
    w.autoStopMinutes  = r.autoStopMinutes;
    w.enablePhoton     = r.enablePhoton;
    _repo.save(w);
    return UseCaseResult!SqlWarehouse(true, "SQL warehouse updated", w);
  }

  UseCaseResult!bool remove(TenantId tenantId, SqlWarehouseId id) {
    auto w = _repo.find(tenantId, id);
    if (w.isNull)
      return UseCaseResult!bool(false, "SQL warehouse not found", false);
    w.state = WarehouseState.deleted;
    _repo.save(w);
    return UseCaseResult!bool(true, "SQL warehouse deleted", true);
  }
}
