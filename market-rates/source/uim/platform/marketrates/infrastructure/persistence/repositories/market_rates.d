/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.infrastructure.persistence.repositories.market_rates;
import uim.platform.marketrates;
import std.algorithm : filter, map;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryMarketRateRepository : TenantRepository!(MarketRate, MarketRateId), MarketRateRepository {

  size_t countByProvider(TenantId t, string code) {
    return findByProvider(t, code).length;
  }

  MarketRate[] filterByProvider(MarketRate[] rates, string code) {
    return rates.filter!(r => r.providerCode == code).array;
  }

  MarketRate[] findByProvider(TenantId t, string code) {
    return filterByProvider(findByTenant(t).array, code);
  }

  void removeByProvider(TenantId t, string code) {
    findByProvider(t, code).each!(r => remove(r));
  }

  size_t countByCategory(TenantId t, MarketDataCategory cat) {
    return findByCategory(t, cat).length;
  }

  MarketRate[] filterByCategory(MarketRate[] rates, MarketDataCategory cat) {
    return rates.filter!(r => r.category == cat).array;
  }
  MarketRate[] findByCategory(TenantId t, MarketDataCategory cat) {
    return findByTenant(t).filter!(r => r.category == cat).array;
  }


  MarketRate[] findByDateRange(TenantId t, string from_, string to_) {
    return findByTenant(t).filter!(r =>
        r.effectiveDate >= from_ &&
        (to_.length == 0 || r.effectiveDate <= to_)
    ).array;
  }

  MarketRate[] findByProviderAndCategory(TenantId t, string code, MarketDataCategory cat) {
    return findByTenant(t).filter!(r => r.providerCode == code && r.category == cat).array;
  }

  MarketRate[] findByKey(TenantId t, string key1, string key2, MarketDataCategory cat) {
    return findByTenant(t).filter!(r =>
        r.key1 == key1 &&
        r.key2 == key2 &&
        r.category == cat
    ).array;
  }

  MarketRate[] findLatest(TenantId t, string code, MarketDataCategory cat) {
    import std.algorithm : sort, uniq;

    auto all = findByProviderAndCategory(t, code, cat);
    if (all.length == 0)
      return all;
    all.sort!((a, b) => a.effectiveDate > b.effectiveDate);
    // Return only the most recent effective date
    string latestDate = all[0].effectiveDate;
    return all.filter!(r => r.effectiveDate == latestDate).array;
  }

  // --- Bulk removal ---
  void removeByProvider(TenantId t, string code) {
    foreach (key, r; findByTenant(t))
      if (r.providerCode == code)
        store.remove(key);
  }

  void removeByCategory(TenantId t, MarketDataCategory cat) {
    foreach (key, r; findByTenant(t))
      if (r.category == cat)
        store.remove(key);
  }

  void removeByDateRange(TenantId t, string from_, string to_) {
    foreach (key, r; findByTenant(t))
      if (r.effectiveDate >= from_ &&
        (to_.length == 0 || r.effectiveDate <= to_))
        store.remove(key);
  }

  size_t countByProvider(TenantId t, string code) {
    return findByProvider(t, code).length;
  }
}
