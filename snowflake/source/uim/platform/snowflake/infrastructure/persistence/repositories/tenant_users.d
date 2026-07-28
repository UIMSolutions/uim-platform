module uim.platform.snowflake.infrastructure.persistence.repositories.tenant_users;
import uim.platform.snowflake;

mixin(ShowModule!());
@safe:
class MemorySnowflakeTenantUserRepository
    : TenantRepository!(SnowflakeTenantUser, SnowflakeTenantUserId),
      SnowflakeTenantUserRepository {

  SnowflakeTenantUser[] findByRole(TenantId tenantId, TenantUserRole role) {
    SnowflakeTenantUser[] result;
    foreach (item; findByTenant(tenantId))
      if (item.role == role) result ~= item;
    return result;
  }

  SnowflakeTenantUser[] findByEmail(TenantId tenantId, string email) {
    SnowflakeTenantUser[] result;
    foreach (item; findByTenant(tenantId))
      if (item.email == email) result ~= item;
    return result;
  }
}
