module uim.platform.integration_suite.domain.ports.repositories.trading_partners;
import uim.platform.integration_suite;
@safe:
interface TradingPartnerRepository : ITentRepository!(TradingPartner, TradingPartnerId) {
  TradingPartner[] findByType(TenantId tenantId, PartnerType partnerType);
  TradingPartner[] findByStandard(TenantId tenantId, B2bStandard standard);
  TradingPartner[] findActive(TenantId tenantId);
}
