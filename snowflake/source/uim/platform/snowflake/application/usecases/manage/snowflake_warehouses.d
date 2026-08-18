module uim.platform.snowflake.application.usecases.manage.snowflake_warehouses;
import uim.platform.snowflake;

mixin(ShowModule!());
@safe:
class ManageSnowflakeWarehousesUseCase {
  protected ISnowflakeWarehouseRepository repo;
  this(ISnowflakeWarehouseRepository repo) { this.repo = repo; }

  UsecaseResult create(CreateWarehouseRequest r) {
    
    SnowflakeWarehouse w;
    w.id = SnowflakeWarehouseId(r.id.length > 0 ? r.id : currentTimestamp());
    w.tenantId = TenantId(r.tenantId);
    w.accountId = SnowflakeAccountId(r.accountId);
    w.name = r.name; w.comment = r.comment;
    w.autoSuspend = r.autoSuspend; w.autoResume = r.autoResume;
    try { w.size = r.size.to!WarehouseSize; } catch(Exception) { w.size = WarehouseSize.xsmall; }
    w.status = WarehouseStatus.starting;
    initEntity(w);
    auto err = SnowflakeValidator.validateWarehouse(w);
    if (err !is null) return UsecaseResult(false, w.id.value, err);
    repo.save(w);
    return UsecaseResult(true, w.id.value, null);
  }

  SnowflakeWarehouse[] list(TenantId tenantId) { return repo.findByTenant(TenantId(tenantId)); }
  SnowflakeWarehouse[] listByAccount(TenantId tenantId, string accountId) {
    return repo.findByAccount(TenantId(tenantId), SnowflakeAccountId(accountId));
  }
  SnowflakeWarehouse getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), SnowflakeWarehouseId(id));
  }

  UsecaseResult update(UpdateWarehouseRequest r) {
    
    auto w = repo.findById(TenantId(r.tenantId), SnowflakeWarehouseId(r.id));
    if (w.isNull) return UsecaseResult(false, r.id, "Warehouse not found");
    if (r.size.length > 0) try { w.size = r.size.to!WarehouseSize; } catch(Exception) {}
    if (r.status.length > 0) try { w.status = r.status.to!WarehouseStatus; } catch(Exception) {}
    if (r.comment.length > 0) w.comment = r.comment;
    if (r.autoSuspend > 0) w.autoSuspend = r.autoSuspend;
    w.autoResume = r.autoResume;
    repo.update(w);
    return UsecaseResult(true, w.id.value, null);
  }

  UsecaseResult remove(TenantId tenantId, string id) {
    auto w = repo.findById(TenantId(tenantId), SnowflakeWarehouseId(id));
    if (w.isNull) return UsecaseResult(false, id, "Warehouse not found");
    repo.remove(TenantId(tenantId), SnowflakeWarehouseId(id));
    return UsecaseResult(true, id, null);
  }
}
