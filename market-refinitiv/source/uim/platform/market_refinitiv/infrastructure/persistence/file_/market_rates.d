module uim.platform.market_refinitiv.infrastructure.persistence.file_.market_rates;

import uim.platform.market_refinitiv;
import uim.platform.market_refinitiv.infrastructure.persistence.codec;
import vibe.data.json : Json, parseJsonString;
import std.file : exists, mkdirRecurse, write, readText, dirEntries, SpanMode, remove;
import std.path : buildPath;
import std.algorithm : filter;
import std.array : array;

@safe:

class FileMarketRateRepository : MarketRateRepository {
  private string basePath;

  this(string rootPath) {
    basePath = buildPath(rootPath, "rates");
  }

  override MarketRate findById(TenantId tenantId, MarketRateId id) @trusted {
    auto p = filePath(tenantId, id.value);
    if (!p.exists) return MarketRate.init;
    return marketRateFromJson(parseJsonString(readText(p)));
  }

  override MarketRate[] findByTenant(TenantId tenantId) @trusted {
    auto dir = tenantDir(tenantId);
    if (!dir.exists) return [];

    MarketRate[] results;
    foreach (e; dirEntries(dir, "*.json", SpanMode.shallow)) {
      try {
        results ~= marketRateFromJson(parseJsonString(readText(e.name)));
      } catch (Exception) {}
    }
    return results;
  }

  override void save(MarketRate rate) {
    ensureTenantDir(rate.tenantId);
    write(filePath(rate.tenantId, rate.id.value), toJsonDoc(rate).toPrettyString());
  }

  override void saveAll(MarketRate[] rates) {
    foreach (r; rates) save(r);
  }

  override void update(MarketRate rate) {
    save(rate);
  }

  override void remove(MarketRate rate) @trusted {
    auto p = filePath(rate.tenantId, rate.id.value);
    if (p.exists) std.file.remove(p);
  }

  override MarketRate[] findByProvider(TenantId tenantId, string providerCode) {
    return findByTenant(tenantId).filter!(r => r.providerCode == providerCode).array;
  }

  override MarketRate[] findByCategory(TenantId tenantId, MarketDataCategory category) {
    return findByTenant(tenantId).filter!(r => r.category == category).array;
  }

  override MarketRate[] findByDateRange(TenantId tenantId, string fromDate, string toDate) {
    return findByTenant(tenantId).filter!(r =>
      r.effectiveDate >= fromDate &&
      (toDate.length == 0 || r.effectiveDate <= toDate)
    ).array;
  }

  override MarketRate[] findByProviderAndCategory(TenantId tenantId, string providerCode, MarketDataCategory category) {
    return findByTenant(tenantId).filter!(r => r.providerCode == providerCode && r.category == category).array;
  }

  override MarketRate[] findByKey(TenantId tenantId, string key1, string key2, MarketDataCategory category) {
    return findByTenant(tenantId).filter!(r =>
      r.key1 == key1 && r.key2 == key2 && r.category == category
    ).array;
  }

  override MarketRate[] findLatest(TenantId tenantId, string providerCode, MarketDataCategory category) {
    auto all = findByProviderAndCategory(tenantId, providerCode, category);
    if (all.length == 0) return all;

    string latest = all[0].effectiveDate;
    foreach (r; all) {
      if (r.effectiveDate > latest) latest = r.effectiveDate;
    }
    return all.filter!(r => r.effectiveDate == latest).array;
  }

  override void removeByProvider(TenantId tenantId, string providerCode) {
    foreach (r; findByProvider(tenantId, providerCode)) remove(r);
  }

  override void removeByCategory(TenantId tenantId, MarketDataCategory category) {
    foreach (r; findByCategory(tenantId, category)) remove(r);
  }

  override void removeByDateRange(TenantId tenantId, string fromDate, string toDate) {
    foreach (r; findByDateRange(tenantId, fromDate, toDate)) remove(r);
  }

  override size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  override size_t countByProvider(TenantId tenantId, string providerCode) {
    return findByProvider(tenantId, providerCode).length;
  }

  private string tenantDir(TenantId tenantId) const {
    return buildPath(basePath, tenantId);
  }

  private string filePath(TenantId tenantId, string id) const {
    return buildPath(tenantDir(tenantId), id ~ ".json");
  }

  private void ensureTenantDir(TenantId tenantId) @trusted {
    auto dir = tenantDir(tenantId);
    if (!dir.exists) mkdirRecurse(dir);
  }
}
