/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.infrastructure.persistence.repositories.market_rates;

import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

class MarketRateRepository : TenantRepository!(MarketRate, MarketRateId), IMarketRateRepository {

  // #region ByProvider
  size_t countByProvider(TenantId tenantId, string code) {
    return findByProvider(tenantId, code).length;
  }

  MarketRate[] filterByProvider(MarketRate[] rates, string code) {
    return rates.filter!(r => r.providerCode == code).array;
  }

  MarketRate[] findByProvider(TenantId tenantId, string code) {
    return filterByProvider(findByTenant(tenantId), code);
  }

  void removeByProvider(TenantId tenantId, string code) {
    findByProvider(tenantId, code).each!(e => remove(e));
  }
  // #endregion ByProvider

  // #region ByCategory
  size_t countByCategory(TenantId tenantId, MarketDataCategory cat) {
    return findByCategory(tenantId, cat).length;
  }

  MarketRate[] filterByCategory(MarketRate[] rates, MarketDataCategory cat) {
    return rates.filter!(r => r.category == cat).array;
  }

  MarketRate[] findByCategory(TenantId tenantId, MarketDataCategory cat) {
    return store.values.filter!(r => r.tenantId == tenantId && r.category == cat).array;
  }

  void removeByCategory(TenantId tenantId, MarketDataCategory cat) {
    findByCategory(tenantId, cat).each!(e => remove(e));
  }
  // #endregion ByCategory

  MarketRate[] filterByDateRange(MarketRate[] rates, string from_, string to_) {
    return rates.filter!(r => r.effectiveDate >= from_ && (to_.length == 0 || r.effectiveDate <= to_)).array;
  }
  MarketRate[] filterByProviderAndCategory(MarketRate[] rates, string code, MarketDataCategory cat) {
    return filterByCategory(filterByProvider(rates, code), cat);
  }
  MarketRate[] filterByKey(MarketRate[] rates, string key1, string key2, MarketDataCategory cat) {
    return filterByCategory(rates, cat).filter!(r => r.key1 == key1 && r.key2 == key2).array;
  }
  MarketRate[] filterLatest(MarketRate[] rates, string code, MarketDataCategory cat) {
    return filterByCategory(filterByProvider(rates, code), cat);
  }

  override MarketRate[] findByDateRange(TenantId tenantId, string from_, string to_) {
    return findByTenant(tenantId).filter!(r =>
      r.effectiveDate >= from_ &&
      (to_.length == 0 || r.effectiveDate <= to_)
    ).array;
  }
  
  MarketRate[] findByProviderAndCategory(TenantId tenantId, string code, MarketDataCategory cat) {
    return findByTenant(tenantId).filter!(r => r.providerCode == code && r.category == cat).array;
  }
  
  MarketRate[] findByKey(TenantId tenantId, string key1, string key2, MarketDataCategory cat) {
    return findByTenant(tenantId).filter!(r =>
      r.key1 == key1 &&
      r.key2 == key2 &&
      r.category == cat
    ).array;
  }
  MarketRate[] findLatest(TenantId tenantId, string code, MarketDataCategory cat) {
    import std.algorithm : sort, uniq;
    auto all = findByProviderAndCategory(tenantId, code, cat);
    if (all.length == 0) return all;
    all.sort!((a, b) => a.effectiveDate > b.effectiveDate);
    // Return only the most recent effective date
    string latestDate = all[0].effectiveDate;
    return all.filter!(r => r.effectiveDate == latestDate).array;
  }

  void removeByDateRange(TenantId tenantId, string from_, string to_) {
    foreach (key, r; findByDateRange(tenantId, from_, to_))
      if (r.tenantId == tenantId && r.effectiveDate >= from_ &&
          (to_.length == 0 || r.effectiveDate <= to_))
        store.remove(key);
  }

  void saveAll(MarketRate[] rates) {
    foreach (r; rates)
      save(r);
  }

}
