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

class MarketRateRepository : TenantRepository!(MarketRate, MarketRateId), IMarketRateRepository {

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
    findByProvider(tenantId, code).each!(r => remove(r));
  }

  size_t countByCategory(TenantId tenantId, MarketDataCategory cat) {
    return findByCategory(tenantId, cat).length;
  }

  MarketRate[] filterByCategory(MarketRate[] rates, MarketDataCategory cat) {
    return rates.filter!(r => r.category == cat).array;
  }

  MarketRate[] findByCategory(TenantId tenantId, MarketDataCategory cat) {
    return filterByCategory(findByTenant(tenantId), cat);
  }

  void removeByCategory(TenantId tenantId, MarketDataCategory cat) {
    findByCategory(tenantId, cat).each!(r => remove(r));
  }

  size_t countByDateRange(TenantId tenantId, string from_, string to_) {
    return findByDateRange(tenantId, from_, to_).length;
  }

  MarketRate[] filterByDateRange(MarketRate[] rates, string from_, string to_) {
    return rates.filter!(r =>
        r.effectiveDate >= from_ &&
        (to_.length == 0 || r.effectiveDate <= to_)
    ).array;
  }

  MarketRate[] findByDateRange(TenantId tenantId, string from_, string to_) {
    return filterByDateRange(findByTenant(tenantId), from_, to_);
  }

  void removeByDateRange(TenantId tenantId, string from_, string to_) {
    findByDateRange(tenantId, from_, to_).each!(r => remove(r));
  }

  size_t countByProviderAndCategory(TenantId tenantId, string code, MarketDataCategory cat) {
    return findByProviderAndCategory(tenantId, code, cat).length;
  }

  MarketRate[] filterByProviderAndCategory(MarketRate[] rates, string code, MarketDataCategory cat) {
    return rates.filter!(r => r.providerCode == code && r.category == cat).array;
  }

  MarketRate[] findByProviderAndCategory(TenantId tenantId, string code, MarketDataCategory cat) {
    return filterByProviderAndCategory(findByTenant(tenantId), code, cat);
  }

  void removeByProviderAndCategory(TenantId tenantId, string code, MarketDataCategory cat) {
    findByProviderAndCategory(tenantId, code, cat).each!(r => remove(r));
  }

  size_t countByKey(TenantId tenantId, string key1, string key2, MarketDataCategory cat) {
    return findByKey(tenantId, key1, key2, cat).length;
  }

  MarketRate[] filterByKey(MarketRate[] rates, string key1, string key2, MarketDataCategory cat) {
    return rates.filter!(r => r.key1 == key1 && r.key2 == key2 && r.category == cat).array;
  }

  MarketRate[] findByKey(TenantId tenantId, string key1, string key2, MarketDataCategory cat) {
    return filterByKey(findByTenant(tenantId), key1, key2, cat);
  }

  void removeByKey(TenantId tenantId, string key1, string key2, MarketDataCategory cat) {
    findByKey(tenantId, key1, key2, cat).each!(r => remove(r));
  }

  size_t countLatest(TenantId tenantId, string code, MarketDataCategory cat) {
    return findLatest(tenantId, code, cat).length;
  }

  MarketRate[] findLatest(TenantId tenantId, string code, MarketDataCategory cat) {
    import std.algorithm : sort, uniq;

    auto all = findByProviderAndCategory(tenantId, code, cat);
    if (all.length == 0)
      return all;
    all.sort!((a, b) => a.effectiveDate > b.effectiveDate);
    // Return only the most recent effective date
    string latestDate = all[0].effectiveDate;
    return all.filter!(r => r.effectiveDate == latestDate).array;
  }

  void saveAll(MarketRate[] rates) {
    rates.each!(r => save(r));
  }
}
