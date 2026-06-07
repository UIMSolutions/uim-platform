module uim.platform.snowflake.application.usecases.manage.tenant_users;
import uim.platform.snowflake;
// mixin(ShowModule!());
@safe:
class ManageSnowflakeTenantUsersUseCase {
  private SnowflakeTenantUserRepository repo;
  this(SnowflakeTenantUserRepository repo) { this.repo = repo; }

  CommandResult create(CreateTenantUserRequest r) {
    
    SnowflakeTenantUser u;
    u.id = SnowflakeTenantUserId(r.id.length > 0 ? r.id : currentTimestamp());
    u.tenantId = TenantId(r.tenantId);
    u.email = r.email; u.firstName = r.firstName; u.lastName = r.lastName;
    u.externalUserId = r.externalUserId; u.active = true;
    try { u.role = r.role.to!TenantUserRole; } catch(Exception) { u.role = TenantUserRole.viewer; }
    initEntity(u);
    auto err = SnowflakeValidator.validateTenantUser(u);
    if (err !is null) return CommandResult(false, u.id.value, err);
    repo.save(u);
    return CommandResult(true, u.id.value, null);
  }

  SnowflakeTenantUser[] list(TenantId tenantId) { return repo.findByTenant(TenantId(tenantId)); }
  SnowflakeTenantUser[] listByRole(TenantId tenantId, string roleStr) {
    
    TenantUserRole r;
    try { r = roleStr.to!TenantUserRole; } catch(Exception) { r = TenantUserRole.viewer; }
    return repo.findByRole(TenantId(tenantId), r);
  }
  SnowflakeTenantUser getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), SnowflakeTenantUserId(id));
  }

  CommandResult update(UpdateTenantUserRequest r) {
    
    auto u = repo.findById(TenantId(r.tenantId), SnowflakeTenantUserId(r.id));
    if (u.isNull) return CommandResult(false, r.id, "User not found");
    if (r.firstName.length > 0) u.firstName = r.firstName;
    if (r.lastName.length > 0) u.lastName = r.lastName;
    if (r.role.length > 0) try { u.role = r.role.to!TenantUserRole; } catch(Exception) {}
    u.active = r.active;
    repo.update(u);
    return CommandResult(true, u.id.value, null);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto u = repo.findById(TenantId(tenantId), SnowflakeTenantUserId(id));
    if (u.isNull) return CommandResult(false, id, "User not found");
    repo.remove(TenantId(tenantId), SnowflakeTenantUserId(id));
    return CommandResult(true, id, null);
  }
}
