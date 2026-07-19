module uim.platform.snowflake.application.usecases.manage.snowflake_warehouses;
import uim.platform.snowflake;

mixin(ShowModule!());
@safe:
class ManageSnowflakeWarehousesUseCase {
  private SnowflakeWarehouseRepository repo;
  this(SnowflakeWarehouseRepository repo) { this.repo = repo; }

  CommandResult create(CreateWarehouseRequest r) {
    
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
    if (err !is null) return CommandResult(false, w.id.value, err);
    repo.save(w);
    return CommandResult(true, w.id.value, null);
  }

  SnowflakeWarehouse[] list(TenantId tenantId) { return repo.findByTenant(TenantId(tenantId)); }
  SnowflakeWarehouse[] listByAccount(TenantId tenantId, string accountId) {
    return repo.findByAccount(TenantId(tenantId), SnowflakeAccountId(accountId));
  }
  SnowflakeWarehouse getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), SnowflakeWarehouseId(id));
  }

  CommandResult update(UpdateWarehouseRequest r) {
    
    auto w = repo.findById(TenantId(r.tenantId), SnowflakeWarehouseId(r.id));
    if (w.isNull) return CommandResult(false, r.id, "Warehouse not found");
    if (r.size.length > 0) try { w.size = r.size.to!WarehouseSize; } catch(Exception) {}
    if (r.status.length > 0) try { w.status = r.status.to!WarehouseStatus; } catch(Exception) {}
    if (r.comment.length > 0) w.comment = r.comment;
    if (r.autoSuspend > 0) w.autoSuspend = r.autoSuspend;
    w.autoResume = r.autoResume;
    repo.update(w);
    return CommandResult(true, w.id.value, null);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto w = repo.findById(TenantId(tenantId), SnowflakeWarehouseId(id));
    if (w.isNull) return CommandResult(false, id, "Warehouse not found");
    repo.remove(TenantId(tenantId), SnowflakeWarehouseId(id));
    return CommandResult(true, id, null);
  }
}
