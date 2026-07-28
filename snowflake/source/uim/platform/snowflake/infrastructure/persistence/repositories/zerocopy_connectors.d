module uim.platform.snowflake.infrastructure.persistence.repositories.zerocopy_connectors;
import uim.platform.snowflake;

mixin(ShowModule!());
@safe:
class MemoryZerocopyConnectorRepository
    : TenantRepository!(ZerocopyConnector, ZerocopyConnectorId),
      ZerocopyConnectorRepository {

  ZerocopyConnector[] findByAccount(TenantId tenantId, SnowflakeAccountId accountId) {
    ZerocopyConnector[] result;
    foreach (item; findByTenant(tenantId))
      if (item.accountId.value == accountId.value) result ~= item;
    return result;
  }

  ZerocopyConnector[] findByStatus(TenantId tenantId, ConnectorStatus status) {
    ZerocopyConnector[] result;
    foreach (item; findByTenant(tenantId))
      if (item.status == status) result ~= item;
    return result;
  }
}
