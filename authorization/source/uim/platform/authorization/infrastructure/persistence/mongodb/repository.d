module uim.platform.authorization.infrastructure.persistence.mongodb.repository;

import std.stdio : writeln;
import std.algorithm : filter;
import vibe.data.bson : Bson;
import vibe.db.mongo.mongo : MongoCollection, connectMongoDB, UpdateFlags;
import vibe.data.json : Json;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class MongoAuthorizationRepository : MemoryAuthorizationRepository {
  protected MongoCollection collection;
  private bool isConnected;

  this(string connectionUri, string dbName, string collectionName) @trusted {
    try {
      auto db = connectMongoDB(connectionUri).getDatabase(dbName);
      this.collection = db[collectionName];
      this.isConnected = true;
    } catch (Exception ex) {
      this.isConnected = false;
      writeln("[authorization] MongoDB unavailable, fallback to in-memory: ", ex.msg);
    }
  }

  override void saveApplication(ManagedApplication app) { super.saveApplication(app); persistTenant(app.tenantId); }
  override void deleteApplication(string tenantId, string id) { super.deleteApplication(tenantId, id); persistTenant(tenantId); }
  override void saveApplicationApi(ApplicationApi api) { super.saveApplicationApi(api); persistTenant(api.tenantId); }
  override void deleteApplicationApi(string tenantId, string id) { super.deleteApplicationApi(tenantId, id); persistTenant(tenantId); }
  override void savePolicy(AuthorizationPolicy policy) { super.savePolicy(policy); persistTenant(policy.tenantId); }
  override void deletePolicy(string tenantId, string id) { super.deletePolicy(tenantId, id); persistTenant(tenantId); }
  override void saveAssignment(PolicyAssignment assignment) { super.saveAssignment(assignment); persistTenant(assignment.tenantId); }
  override void deleteAssignment(string tenantId, string id) { super.deleteAssignment(tenantId, id); persistTenant(tenantId); }

private:
  void persistTenant(string tenantId) @trusted {
    if (!isConnected) return;

    auto state = Json.emptyObject;

    auto appArr = Json.emptyArray;
    foreach (a; applications.filter!(e => e.tenantId == tenantId)) appArr ~= a.toJson();
    state["applications"] = appArr;

    auto apiArr = Json.emptyArray;
    foreach (a; apis.filter!(e => e.tenantId == tenantId)) apiArr ~= a.toJson();
    state["apis"] = apiArr;

    auto polArr = Json.emptyArray;
    foreach (p; policies.filter!(e => e.tenantId == tenantId)) polArr ~= p.toJson();
    state["policies"] = polArr;

    auto asgArr = Json.emptyArray;
    foreach (a; assignments.filter!(e => e.tenantId == tenantId)) asgArr ~= a.toJson();
    state["assignments"] = asgArr;

    collection.update(  Bson(["tenantId": Bson(tenantId)]),
      Bson(["$set": Bson(["tenantId": Bson(tenantId), "stateJson": Bson(state.toString())])]),
      UpdateFlags.upsert
    );
  }
}
