module uim.platform.snowflake.domain.ports.repositories.tenant_users;
import uim.platform.snowflake;
@safe:
interface SnowflakeTenantUserRepository : ITenantRepository!(SnowflakeTenantUser, SnowflakeTenantUserId) {
  SnowflakeTenantUser[] findByRole(TenantId tenantId, TenantUserRole role);
  SnowflakeTenantUser[] findByEmail(TenantId tenantId, string email);
}
