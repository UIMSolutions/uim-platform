module uim.platform.analytics.infrastructure.persistence.mongodb.assets;

// import std.process : environment;
// import vibe.db.mongo.mongo : Bson, DeleteOptions, MongoCollection, UpdateOptions, connectMongoDB;
// import uim.platform.analytics.domain;
import uim.platform.analytics;
mixin(ShowModule!());

@safe:  
class MongoAssetRepository : AssetRepository {
  private MongoCollection collection;

  this(MongoCollection collection) {
    this.collection = collection;
  }

  AssetId save(InsightAsset asset) {
    UpdateOptions options;
    options.upsert = true;

    auto query = Bson(["tenantId": Bson(asset.tenantId), "id": Bson(asset.id)]);
    collection.updateOne(query, Bson(["$set": toBson(asset)]), options);
    return asset.id;
  }

  bool update(InsightAsset asset) {
    UpdateOptions options;
    options.upsert = true;

    auto query = Bson(["tenantId": Bson(asset.tenantId), "id": Bson(asset.id)]);
    auto result = collection.updateOne(query, Bson(["$set": toBson(asset)]), options);
    return result.matchedCount > 0 || result.modifiedCount > 0;
  }

  bool remove(TenantId tenantId, AssetId id) {
    DeleteOptions options;
    auto result = collection.deleteOne(Bson(["tenantId": Bson(tenantId), "id": Bson(id)]), options);
    return result.deletedCount > 0;
  }

  InsightAsset findById(TenantId tenantId, AssetId id) {
    auto doc = collection.findOne(Bson(["tenantId": Bson(tenantId), "id": Bson(id)]));
    if (doc.isNull) return InsightAsset.init;
    return fromBson(doc);
  }

  InsightAsset[] findByTenant(TenantId tenantId) {
    InsightAsset[] items;
    foreach (doc; collection.find(Bson(["tenantId": Bson(tenantId)]))) {
      items ~= fromBson(doc);
    }
    return items;
  }

  private InsightAsset fromBson(Bson doc) {
    InsightAsset a;
    a.id = doc["id"].get!string;
    a.tenantId = doc["tenantId"].get!string;
    a.name = doc["name"].get!string;
    a.kind = doc["kind"].get!string;
    a.sourceSystem = doc["sourceSystem"].get!string;
    a.published = doc["published"].get!bool;
    a.createdAt = doc["createdAt"].get!long;
    a.updatedAt = doc["updatedAt"].get!long;

    foreach (d; doc["dimensions"].get!(Bson[])) {
      a.dimensions ~= d.get!string;
    }

    foreach (m; doc["measures"].get!(Bson[])) {
      a.measures ~= m.get!string;
    }

    return a;
  }

  private Bson toBson(InsightAsset a) {
    Bson[] dims;
    foreach (d; a.dimensions) dims ~= Bson(d);

    Bson[] meas;
    foreach (m; a.measures) meas ~= Bson(m);

    return Bson([
      "id": Bson(a.id),
      "tenantId": Bson(a.tenantId),
      "name": Bson(a.name),
      "kind": Bson(a.kind),
      "sourceSystem": Bson(a.sourceSystem),
      "dimensions": Bson(dims),
      "measures": Bson(meas),
      "published": Bson(a.published),
      "createdAt": Bson(a.createdAt),
      "updatedAt": Bson(a.updatedAt)
    ]);
  }
}

unittest {
  auto uri = environment.get("ANALYTICS_TEST_MONGO_URI", "");
  if (uri.length == 0) {
    return;
  }

  auto db = connectMongoDB(uri).getDatabase("analytics_test");
  auto coll = db["insight_assets"];
  auto repo = new MongoAssetRepository(coll);

  coll.deleteMany(Bson(["tenantId": Bson("t-mongo-test")]));

  InsightAsset a;
  a.id = "mongo-1";
  a.tenantId = "t-mongo-test";
  a.name = "Mongo Asset";
  a.kind = "story";
  a.sourceSystem = "datasphere";
  a.dimensions = ["region"];
  a.measures = ["revenue"];
  a.published = false;
  a.createdAt = 1;
  a.updatedAt = 1;

  auto id = repo.save(a);
  assert(id == "mongo-1");

  auto found = repo.findById("t-mongo-test", "mongo-1");
  assert(!found.isNull);
  assert(found.name == "Mongo Asset");

  auto removed = repo.remove("t-mongo-test", "mongo-1");
  assert(removed);
  assert(repo.findById("t-mongo-test", "mongo-1").isNull);
}
