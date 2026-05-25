module uim.platform.snowflake.domain.ports.repositories.snowflake_databases;
import uim.platform.snowflake;
@safe:
interface SnowflakeDatabaseRepository : ITenantRepository!(SnowflakeDatabase, SnowflakeDatabaseId) {
  SnowflakeDatabase[] findByAccount(TenantId tenantId, SnowflakeAccountId accountId);
  SnowflakeDatabase[] findByStatus(TenantId tenantId, DatabaseStatus status);
}
