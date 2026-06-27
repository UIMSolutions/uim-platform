module uim.platform.snowflake.infrastructure.persistence.memory.snowflake_databases;
import uim.platform.snowflake;
// mixin(ShowModule!());
@safe:
class MemorySnowflakeDatabaseRepository
    : TenantRepository!(SnowflakeDatabase, SnowflakeDatabaseId),
      SnowflakeDatabaseRepository {

  SnowflakeDatabase[] findByAccount(TenantId tenantId, SnowflakeAccountId accountId) {
    SnowflakeDatabase[] result;
    foreach (item; findByTenant(tenantId))
      if (item.accountId.value == accountId.value) result ~= item;
    return result;
  }

  SnowflakeDatabase[] findByStatus(TenantId tenantId, DatabaseStatus status) {
    SnowflakeDatabase[] result;
    foreach (item; findByTenant(tenantId))
      if (item.status == status) result ~= item;
    return result;
  }
}
