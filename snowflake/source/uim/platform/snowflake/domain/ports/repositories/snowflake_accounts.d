module uim.platform.snowflake.domain.ports.repositories.snowflake_accounts;
import uim.platform.snowflake;
@safe:
interface ISnowflakeAccountRepository : ITenantRepository!(SnowflakeAccount, SnowflakeAccountId) {
  SnowflakeAccount[] findByStatus(TenantId tenantId, AccountStatus status);
  SnowflakeAccount[] findByRegion(TenantId tenantId, string region);
}
