module uim.platform.snowflake.infrastructure.persistence.memory.snowflake_accounts;
import uim.platform.snowflake;
// mixin(ShowModule!());
@safe:
class MemorySnowflakeAccountRepository
    : TentRepository!(SnowflakeAccount, SnowflakeAccountId),
      SnowflakeAccountRepository {

  SnowflakeAccount[] findByStatus(TenantId tenantId, AccountStatus status) {
    SnowflakeAccount[] result;
    foreach (item; findByTenant(tenantId))
      if (item.status == status) result ~= item;
    return result;
  }

  SnowflakeAccount[] findByRegion(TenantId tenantId, string region) {
    SnowflakeAccount[] result;
    foreach (item; findByTenant(tenantId))
      if (item.region == region) result ~= item;
    return result;
  }
}
