/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.domain.ports.repositories.market_rates;
import uim.platform.marketrates;

// mixin(ShowModule!());

@safe:
interface MarketRateRepository : ITentRepository!(MarketRate, MarketRateId) {

  MarketRate[] findByProvider(TenantId tenantId, string providerCode);
  MarketRate[] findByCategory(TenantId tenantId, MarketDataCategory category);
  MarketRate[] findByDateRange(TenantId tenantId, string fromDate, string toDate);
  MarketRate[] findByProviderAndCategory(TenantId tenantId, string providerCode, MarketDataCategory category);
  MarketRate[] findByKey(TenantId tenantId, string key1, string key2, MarketDataCategory category);
  MarketRate[] findLatest(TenantId tenantId, string providerCode, MarketDataCategory category);

  void saveAll(MarketRate[] rates);
  void removeByProvider(TenantId tenantId, string providerCode);
  void removeByCategory(TenantId tenantId, MarketDataCategory category);
  void removeByDateRange(TenantId tenantId, string fromDate, string toDate);

  size_t countByTenant(TenantId tenantId);
  size_t countByProvider(TenantId tenantId, string providerCode);
}
