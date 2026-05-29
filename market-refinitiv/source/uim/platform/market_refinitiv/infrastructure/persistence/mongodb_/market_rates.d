module uim.platform.market_refinitiv.infrastructure.persistence.mongodb_.market_rates;

import uim.platform.market_refinitiv;
import uim.platform.market_refinitiv.infrastructure.persistence.codec;
import vibe.db.mongo.mongo : MongoCollection, UpdateFlags, connectMongoDB;
import vibe.data.bson : Bson;
import vibe.data.json : parseJsonString;
import std.algorithm : filter;
import std.array : array;

@safe:

class MongoDbMarketRateRepository : MarketRateRepository {
  private MongoCollection collection;

  this(string mongoUri, string dbName) @trusted {
    collection = connectMongoDB(mongoUri)[dbName]["market_rates"];
  }

  override MarketRate findById(TenantId tenantId, MarketRateId id) @trusted {
    auto d = collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
    if (d.isNull) return MarketRate.init;
    return marketRateFromDoc(d);
  }

  override MarketRate[] findByTenant(TenantId tenantId) @trusted {
    MarketRate[] results;
    foreach (d; collection.find(Bson(["tenantId": Bson(tenantId.value)]))) {
      results ~= marketRateFromDoc(d);
    }
    return results;
  }

  override void save(MarketRate rate) @trusted {
    auto q = Bson(["tenantId": Bson(rate.tenantId.value), "id": Bson(rate.id.value)]);
    collection.update(q, Bson(["$set": toDoc(rate)]), UpdateFlags.upsert);
  }

  override void saveAll(MarketRate[] rates) {
    foreach (r; rates) save(r);
  }

  override void update(MarketRate rate) {
    save(rate);
  }

  override void remove(MarketRate rate) @trusted {
    collection.remove(Bson(["tenantId": Bson(rate.tenantId.value), "id": Bson(rate.id.value)]));
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

  private Bson toDoc(MarketRate rate) {
    return Bson([
      "tenantId": Bson(rate.tenantId.value),
      "id": Bson(rate.id.value),
      "providerCode": Bson(rate.providerCode),
      "category": Bson(cast(string) rate.category),
      "effectiveDate": Bson(rate.effectiveDate),
      "payload": Bson(toJsonDoc(rate).toString())
    ]);
  }

  private MarketRate marketRateFromDoc(Bson doc) {
    auto payload = doc["payload"].get!string;
    return marketRateFromJson(parseJsonString(payload));
  }
}
