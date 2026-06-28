module uim.platform.market_refinitiv.infrastructure.persistence.mongodb_.providers;

import uim.platform.market_refinitiv;
import uim.platform.market_refinitiv.infrastructure.persistence.codec;
import vibe.db.mongo.mongo : MongoCollection, UpdateFlags, connectMongoDB;
import vibe.data.bson : Bson;
import vibe.data.json : parseJsonString;
import std.algorithm : filter;
import std.array : array;

@safe:

class MongoDbProviderRepository : ProviderRepository {
  private MongoCollection collection;

  this(string mongoUri, string dbName) @trusted {
    collection = connectMongoDB(mongoUri)[dbName]["providers"];
  }

  override Provider findById(TenantId tenantId, ProviderId id) @trusted {
    auto d = collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
    if (d.isNull) return Provider.init;
    return providerFromDoc(d);
  }

  override Provider[] findByTenant(TenantId tenantId) @trusted {
    Provider[] results;
    foreach (d; collection.find(Bson(["tenantId": Bson(tenantId.value)]))) {
      results ~= providerFromDoc(d);
    }
    return results;
  }

  override void save(Provider provider) @trusted {
    auto q = Bson(["tenantId": Bson(provider.tenantId.value), "id": Bson(provider.id.value)]);
    collection.update(q, Bson(["$set": toDoc(provider)]), UpdateFlags.upsert);
  }

  override void update(Provider provider) {
    save(provider);
  }

  override void remove(Provider provider) @trusted {
    collection.remove(Bson(["tenantId": Bson(provider.tenantId.value), "id": Bson(provider.id.value)]));
  }

  override Provider findByCode(TenantId tenantId, string code) {
    foreach (p; find(tenantId)) {
      if (p.code == code) return p;
    }
    return Provider.init;
  }

  override Provider[] findActive(TenantId tenantId) {
    return find(tenantId).filter!(p => p.isActive).array;
  }

  override bool codeExists(TenantId tenantId, string code) {
    return !findByCode(tenantId, code).isNull;
  }

  private Bson toDoc(Provider provider) {
    return Bson([
      "tenantId": Bson(provider.tenantId.value),
      "id": Bson(provider.id.value),
      "code": Bson(provider.code),
      "isActive": Bson(provider.isActive),
      "payload": Bson(toJsonDoc(provider).toString())
    ]);
  }

  private Provider providerFromDoc(Bson doc) {
    auto payload = doc["payload"].get!string;
    return providerFromJson(parseJsonString(payload));
  }
}
