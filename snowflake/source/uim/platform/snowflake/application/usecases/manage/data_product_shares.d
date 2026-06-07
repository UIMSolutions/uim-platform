module uim.platform.snowflake.application.usecases.manage.data_product_shares;
import uim.platform.snowflake;
// mixin(ShowModule!());
@safe:
class ManageDataProductSharesUseCase {
  private DataProductShareRepository repo;
  this(DataProductShareRepository repo) { this.repo = repo; }

  CommandResult create(CreateShareRequest r) {
    DataProductShare s;
    s.id = DataProductShareId(r.id.length > 0 ? r.id : currentTimestamp());
    s.tenantId = TenantId(r.tenantId);
    s.accountId = SnowflakeAccountId(r.accountId);
    s.connectorId = ZerocopyConnectorId(r.connectorId);
    s.dataProductId = r.dataProductId; s.shareName = r.shareName;
    s.comment = r.comment; s.status = ShareStatus.pending;
    s.metadata = r.metadata;
    initEntity(s);
    auto err = SnowflakeValidator.validateShare(s);
    if (err !is null) return CommandResult(false, s.id.value, err);
    repo.save(s);
    return CommandResult(true, s.id.value, null);
  }

  DataProductShare[] list(TenantId tenantId) { return repo.findByTenant(TenantId(tenantId)); }
  DataProductShare[] listByAccount(TenantId tenantId, string accountId) {
    return repo.findByAccount(TenantId(tenantId), SnowflakeAccountId(accountId));
  }
  DataProductShare[] listByConnector(TenantId tenantId, string connectorId) {
    return repo.findByConnector(TenantId(tenantId), ZerocopyConnectorId(connectorId));
  }
  DataProductShare getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), DataProductShareId(id));
  }

  CommandResult sync_(TenantId tenantId, string id) {
    auto s = repo.findById(TenantId(tenantId), DataProductShareId(id));
    if (s.isNull) return CommandResult(false, id, "Share not found");
    s.status = ShareStatus.syncing;
    s.lastSyncAt = currentTimestamp();
    repo.update(s);
    return CommandResult(true, id, null);
  }

  CommandResult update(UpdateShareRequest r) {
    
    auto s = repo.findById(TenantId(r.tenantId), DataProductShareId(r.id));
    if (s.isNull) return CommandResult(false, r.id, "Share not found");
    if (r.status.length > 0) try { s.status = r.status.to!ShareStatus; } catch(Exception) {}
    if (r.comment.length > 0) s.comment = r.comment;
    repo.update(s);
    return CommandResult(true, s.id.value, null);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto s = repo.findById(TenantId(tenantId), DataProductShareId(id));
    if (s.isNull) return CommandResult(false, id, "Share not found");
    repo.remove(TenantId(tenantId), DataProductShareId(id));
    return CommandResult(true, id, null);
  }
}
