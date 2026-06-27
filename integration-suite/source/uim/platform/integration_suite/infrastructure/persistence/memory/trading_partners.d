module uim.platform.integration_suite.infrastructure.persistence.memory.trading_partners;
import uim.platform.integration_suite;

// mixin(ShowModule!());

@safe:

class MemoryTradingPartnerRepository
    : TentRepository!(TradingPartner, TradingPartnerId),
      TradingPartnerRepository {

  TradingPartner[] findByType(TenantId tenantId, PartnerType partnerType) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(p => p.partnerType == partnerType).array;
  }

  TradingPartner[] findByStandard(TenantId tenantId, B2bStandard standard) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(p => p.standard == standard).array;
  }

  TradingPartner[] findActive(TenantId tenantId) {
    import std.algorithm : filter;
    import std.array : array;
    return getAll(tenantId).filter!(p => p.active).array;
  }
}
