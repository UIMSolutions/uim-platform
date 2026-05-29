module uim.platform.market_refinitiv.infrastructure.persistence.mongodb_.audit_logs;

import uim.platform.market_refinitiv;
import uim.platform.market_refinitiv.infrastructure.persistence.codec;
import vibe.db.mongo.mongo : MongoCollection, UpdateFlags, connectMongoDB;
import vibe.data.bson : Bson;
import vibe.data.json : parseJsonString;
import std.algorithm : filter;
import std.array : array;
import std.conv : to;

@safe:

class MongoDbAuditLogRepository : AuditLogRepository {
  private MongoCollection collection;

  this(string mongoUri, string dbName) @trusted {
    collection = connectMongoDB(mongoUri)[dbName]["audit_logs"];
  }

  override AuditLog findById(TenantId tenantId, AuditLogId id) @trusted {
    auto d = collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
    if (d.isNull) return AuditLog.init;
    return auditLogFromDoc(d);
  }

  override AuditLog[] findByTenant(TenantId tenantId) @trusted {
    AuditLog[] results;
    foreach (d; collection.find(Bson(["tenantId": Bson(tenantId.value)]))) {
      results ~= auditLogFromDoc(d);
    }
    return results;
  }

  override void save(AuditLog log) @trusted {
    auto q = Bson(["tenantId": Bson(log.tenantId.value), "id": Bson(log.id.value)]);
    collection.update(q, Bson(["$set": toDoc(log)]), UpdateFlags.upsert);
  }

  override void update(AuditLog log) {
    save(log);
  }

  override void remove(AuditLog log) @trusted {
    collection.remove(Bson(["tenantId": Bson(log.tenantId.value), "id": Bson(log.id.value)]));
  }

  override AuditLog[] findByOperation(TenantId tenantId, AuditOperation op) {
    return findByTenant(tenantId).filter!(e => e.operation == op).array;
  }

  override AuditLog[] findByProvider(TenantId tenantId, string providerCode) {
    return findByTenant(tenantId).filter!(e => e.providerCode == providerCode).array;
  }

  override AuditLog[] findByStatus(TenantId tenantId, OperationStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).array;
  }

  override AuditLog[] findByDateRange(TenantId tenantId, string fromDate, string toDate) {
    return findByTenant(tenantId).filter!(e =>
      e.fromDate >= fromDate &&
      (toDate.length == 0 || e.toDate <= toDate)
    ).array;
  }

  private Bson toDoc(AuditLog log) {
    return Bson([
      "tenantId": Bson(log.tenantId.value),
      "id": Bson(log.id.value),
      "providerCode": Bson(log.providerCode),
      "operation": Bson(log.operation.to!string),
      "status": Bson(log.status.to!string),
      "payload": Bson(toJsonDoc(log).toString())
    ]);
  }

  private AuditLog auditLogFromDoc(Bson doc) {
    auto payload = doc["payload"].get!string;
    return auditLogFromJson(parseJsonString(payload));
  }
}
