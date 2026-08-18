module uim.platform.snowflake.application.usecases.manage.snowflake_roles;
import uim.platform.snowflake;

mixin(ShowModule!());
@safe:
class ManageSnowflakeRolesUseCase {
  protected ISnowflakeRoleRepository repo;
  this(ISnowflakeRoleRepository repo) { this.repo = repo; }

  UsecaseResult create(CreateRoleRequest r) {
    SnowflakeRole role;
    role.id = SnowflakeRoleId(r.id.length > 0 ? r.id : currentTimestamp());
    role.tenantId = TenantId(r.tenantId);
    role.accountId = SnowflakeAccountId(r.accountId);
    role.name = r.name; role.description = r.description;
    role.privileges = r.privileges; role.active = true;
    initEntity(role);
    auto err = SnowflakeValidator.validateRole(role);
    if (err !is null) return UsecaseResult(false, role.id.value, err);
    repo.save(role);
    return UsecaseResult(true, role.id.value, null);
  }

  SnowflakeRole[] list(TenantId tenantId) { return repo.findByTenant(TenantId(tenantId)); }
  SnowflakeRole[] listByAccount(TenantId tenantId, string accountId) {
    return repo.findByAccount(TenantId(tenantId), SnowflakeAccountId(accountId));
  }
  SnowflakeRole getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), SnowflakeRoleId(id));
  }

  UsecaseResult update(UpdateRoleRequest r) {
    auto role = repo.findById(TenantId(r.tenantId), SnowflakeRoleId(r.id));
    if (role.isNull) return UsecaseResult(false, r.id, "Role not found");
    if (r.description.length > 0) role.description = r.description;
    if (r.privileges.length > 0) role.privileges = r.privileges;
    role.active = r.active;
    repo.update(role);
    return UsecaseResult(true, role.id.value, null);
  }

  UsecaseResult remove(TenantId tenantId, string id) {
    auto role = repo.findById(TenantId(tenantId), SnowflakeRoleId(id));
    if (role.isNull) return UsecaseResult(false, id, "Role not found");
    repo.remove(TenantId(tenantId), SnowflakeRoleId(id));
    return UsecaseResult(true, id, null);
  }
}
