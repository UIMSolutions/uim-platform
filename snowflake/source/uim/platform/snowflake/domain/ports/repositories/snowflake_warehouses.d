module uim.platform.snowflake.domain.ports.repositories.snowflake_warehouses;
import uim.platform.snowflake;
@safe:
interface ISnowflakeWarehouseRepository : ITenantRepository!(SnowflakeWarehouse, SnowflakeWarehouseId) {
  SnowflakeWarehouse[] findByAccount(TenantId tenantId, SnowflakeAccountId accountId);
  SnowflakeWarehouse[] findByStatus(TenantId tenantId, WarehouseStatus status);
}
