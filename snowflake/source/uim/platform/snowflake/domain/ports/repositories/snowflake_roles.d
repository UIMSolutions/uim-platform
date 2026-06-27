module uim.platform.snowflake.domain.ports.repositories.snowflake_roles;
import uim.platform.snowflake;
@safe:
interface SnowflakeRoleRepository : ITenantRepository!(SnowflakeRole, SnowflakeRoleId) {
  SnowflakeRole[] findByAccount(TenantId tenantId, SnowflakeAccountId accountId);
  SnowflakeRole[] findActive(TenantId tenantId);
}
