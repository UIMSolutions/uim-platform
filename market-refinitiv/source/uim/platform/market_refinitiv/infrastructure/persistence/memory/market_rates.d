/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.infrastructure.persistence.memory.market_rates;
import uim.platform.marketrates;
import std.algorithm : filter, map;
import std.array     : array;

mixin(ShowModule!());

@safe:

class MemoryMarketRateRepository : MarketRateRepository {
  private MarketRate[string] store;

  // --- ITenantRepository ---
  override MarketRate   findById(TenantId t, MarketRateId id) {
    if (auto p = id.value in store) return *p;
    MarketRate empty; return empty;
  }
  override MarketRate[] findByTenant(TenantId t) {
    return store.values.filter!(r => r.tenantId == t).array;
  }
  override void save(MarketRate r)   { store[r.id.value] = r; }
  override void saveAll(MarketRate[] rates) { foreach (r; rates) store[r.id.value] = r; }
  override void update(MarketRate r) { store[r.id.value] = r; }
  override void remove(MarketRate r) { store.remove(r.id.value); }

  // --- Querying ---
  override MarketRate[] findByProvider(TenantId t, string code) {
    return store.values.filter!(r => r.tenantId == t && r.providerCode == code).array;
  }
  override MarketRate[] findByCategory(TenantId t, MarketDataCategory cat) {
    return store.values.filter!(r => r.tenantId == t && r.category == cat).array;
  }
  override MarketRate[] findByDateRange(TenantId t, string from_, string to_) {
    return store.values.filter!(r =>
      r.tenantId == t &&
      r.effectiveDate >= from_ &&
      (to_.length == 0 || r.effectiveDate <= to_)
    ).array;
  }
  override MarketRate[] findByProviderAndCategory(TenantId t, string code, MarketDataCategory cat) {
    return store.values.filter!(r => r.tenantId == t && r.providerCode == code && r.category == cat).array;
  }
  override MarketRate[] findByKey(TenantId t, string key1, string key2, MarketDataCategory cat) {
    return store.values.filter!(r =>
      r.tenantId == t &&
      r.key1 == key1 &&
      r.key2 == key2 &&
      r.category == cat
    ).array;
  }
  override MarketRate[] findLatest(TenantId t, string code, MarketDataCategory cat) {
    import std.algorithm : sort, uniq;
    auto all = findByProviderAndCategory(t, code, cat);
    if (all.length == 0) return all;
    all.sort!((a, b) => a.effectiveDate > b.effectiveDate);
    // Return only the most recent effective date
    string latestDate = all[0].effectiveDate;
    return all.filter!(r => r.effectiveDate == latestDate).array;
  }

  // --- Bulk removal ---
  override void removeByProvider(TenantId t, string code) {
    foreach (key, r; store)
      if (r.tenantId == t && r.providerCode == code)
        store.remove(key);
  }
  override void removeByCategory(TenantId t, MarketDataCategory cat) {
    foreach (key, r; store)
      if (r.tenantId == t && r.category == cat)
        store.remove(key);
  }
  override void removeByDateRange(TenantId t, string from_, string to_) {
    foreach (key, r; store)
      if (r.tenantId == t && r.effectiveDate >= from_ &&
          (to_.length == 0 || r.effectiveDate <= to_))
        store.remove(key);
  }

  // --- Counts ---
  override size_t countByTenant(TenantId t) {
    return store.values.filter!(r => r.tenantId == t).array.length;
  }
  override size_t countByProvider(TenantId t, string code) {
    return findByProvider(t, code).length;
  }
}
