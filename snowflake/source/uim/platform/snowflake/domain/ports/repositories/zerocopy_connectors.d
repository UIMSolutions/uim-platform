module uim.platform.snowflake.domain.ports.repositories.zerocopy_connectors;
import uim.platform.snowflake;
@safe:
interface ZerocopyConnectorRepository : ITentRepository!(ZerocopyConnector, ZerocopyConnectorId) {
  ZerocopyConnector[] findByAccount(TenantId tenantId, SnowflakeAccountId accountId);
  ZerocopyConnector[] findByStatus(TenantId tenantId, ConnectorStatus status);
}
