module uim.platform.snowflake.infrastructure.persistence.memory.snowflake_warehouses;
import uim.platform.snowflake;
// mixin(ShowModule!());
@safe:
class MemorySnowflakeWarehouseRepository
    : TenantRepository!(SnowflakeWarehouse, SnowflakeWarehouseId),
      SnowflakeWarehouseRepository {

  SnowflakeWarehouse[] findByAccount(TenantId tenantId, SnowflakeAccountId accountId) {
    SnowflakeWarehouse[] result;
    foreach (item; findByTenant(tenantId))
      if (item.accountId.value == accountId.value) result ~= item;
    return result;
  }

  SnowflakeWarehouse[] findByStatus(TenantId tenantId, WarehouseStatus status) {
    SnowflakeWarehouse[] result;
    foreach (item; findByTenant(tenantId))
      if (item.status == status) result ~= item;
    return result;
  }
}
