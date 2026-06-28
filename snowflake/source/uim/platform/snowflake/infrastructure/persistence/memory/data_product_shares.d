module uim.platform.snowflake.infrastructure.persistence.memory.data_product_shares;
import uim.platform.snowflake;
// mixin(ShowModule!());
@safe:
class MemoryDataProductShareRepository
    : TenantRepository!(DataProductShare, DataProductShareId),
      DataProductShareRepository {

  DataProductShare[] findByAccount(TenantId tenantId, SnowflakeAccountId accountId) {
    DataProductShare[] result;
    foreach (item; find(tenantId))
      if (item.accountId.value == accountId.value) result ~= item;
    return result;
  }

  DataProductShare[] findByConnector(TenantId tenantId, ZerocopyConnectorId connectorId) {
    DataProductShare[] result;
    foreach (item; find(tenantId))
      if (item.connectorId.value == connectorId.value) result ~= item;
    return result;
  }

  DataProductShare[] findByStatus(TenantId tenantId, ShareStatus status) {
    DataProductShare[] result;
    foreach (item; find(tenantId))
      if (item.status == status) result ~= item;
    return result;
  }
}
