module uim.platform.snowflake.infrastructure.persistence.memory.snowflake_roles;
import uim.platform.snowflake;
// mixin(ShowModule!());
@safe:
class MemorySnowflakeRoleRepository
    : TenantRepository!(SnowflakeRole, SnowflakeRoleId),
      SnowflakeRoleRepository {

  SnowflakeRole[] findByAccount(TenantId tenantId, SnowflakeAccountId accountId) {
    SnowflakeRole[] result;
    foreach (item; find(tenantId))
      if (item.accountId.value == accountId.value) result ~= item;
    return result;
  }

  SnowflakeRole[] findActive(TenantId tenantId) {
    SnowflakeRole[] result;
    foreach (item; find(tenantId))
      if (item.active) result ~= item;
    return result;
  }
}
