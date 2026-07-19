module uim.platform.snowflake.application.usecases.manage.snowflake_accounts;
import uim.platform.snowflake;

mixin(ShowModule!());
@safe:
class ManageSnowflakeAccountsUseCase {
  private SnowflakeAccountRepository repo;
  this(SnowflakeAccountRepository repo) { this.repo = repo; }

  CommandResult create(CreateAccountRequest r) {
    SnowflakeAccount a;
    a.id = SnowflakeAccountId(r.id.length > 0 ? r.id : currentTimestamp());
    a.tenantId = TenantId(r.tenantId);
    a.name = r.name; a.region = r.region;
    a.adminEmail = r.adminEmail; a.adminFirstName = r.adminFirstName; a.adminLastName = r.adminLastName;
    a.entitlementSystemId = r.entitlementSystemId;
    a.status = AccountStatus.pending;
    a.metadata = r.metadata;
    initEntity(a);
    auto err = SnowflakeValidator.validateAccount(a);
    if (err !is null) return CommandResult(false, a.id.value, err);
    repo.save(a);
    return CommandResult(true, a.id.value, null);
  }

  SnowflakeAccount[] list(TenantId tenantId) { return repo.findByTenant(TenantId(tenantId)); }

  SnowflakeAccount getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), SnowflakeAccountId(id));
  }

  CommandResult update(UpdateAccountRequest r) {
    auto a = repo.findById(TenantId(r.tenantId), SnowflakeAccountId(r.id));
    if (a.isNull) return CommandResult(false, r.id, "Account not found");
    if (r.name.length > 0) a.name = r.name;
    if (r.status.length > 0) {  try { a.status = r.status.to!AccountStatus; } catch(Exception) {} }
    repo.update(a);
    return CommandResult(true, a.id.value, null);
  }

  CommandResult activate(TenantId tenantId, string id) {
    auto a = repo.findById(TenantId(tenantId), SnowflakeAccountId(id));
    if (a.isNull) return CommandResult(false, id, "Account not found");
    a.status = AccountStatus.active;
    a.activatedAt = currentTimestamp();
    repo.update(a);
    return CommandResult(true, id, null);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto a = repo.findById(TenantId(tenantId), SnowflakeAccountId(id));
    if (a.isNull) return CommandResult(false, id, "Account not found");
    repo.remove(TenantId(tenantId), SnowflakeAccountId(id));
    return CommandResult(true, id, null);
  }
}
