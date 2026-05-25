module uim.platform.snowflake.domain.ports.repositories.data_product_shares;
import uim.platform.snowflake;
@safe:
interface DataProductShareRepository : ITenantRepository!(DataProductShare, DataProductShareId) {
  DataProductShare[] findByAccount(TenantId tenantId, SnowflakeAccountId accountId);
  DataProductShare[] findByConnector(TenantId tenantId, ZerocopyConnectorId connectorId);
  DataProductShare[] findByStatus(TenantId tenantId, ShareStatus status);
}
