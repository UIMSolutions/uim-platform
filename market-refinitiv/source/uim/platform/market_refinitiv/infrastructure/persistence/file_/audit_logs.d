module uim.platform.market_refinitiv.infrastructure.persistence.file_.audit_logs;

import uim.platform.market_refinitiv;
import uim.platform.market_refinitiv.infrastructure.persistence.codec;
import vibe.data.json : parseJsonString;
import std.file : exists, mkdirRecurse, append, readText;
import std.path : buildPath;
import std.algorithm : filter;
import std.array : array;
import std.string : splitLines;

@safe:

class FileAuditLogRepository : AuditLogRepository {
  private string basePath;

  this(string rootPath) {
    basePath = buildPath(rootPath, "audit");
  }

  override AuditLog findById(TenantId tenantId, AuditLogId id) {
    foreach (e; findByTenant(tenantId)) {
      if (e.id == id) return e;
    }
    return AuditLog.init;
  }

  override AuditLog[] findByTenant(TenantId tenantId) @trusted {
    auto p = logPath(tenantId);
    if (!p.exists) return [];

    AuditLog[] results;
    foreach (line; readText(p).splitLines()) {
      if (line.length == 0) continue;
      try {
        results ~= auditLogFromJson(parseJsonString(line));
      } catch (Exception) {}
    }
    return results;
  }

  override void save(AuditLog log) @trusted {
    ensureTenantDir(log.tenantId);
    append(logPath(log.tenantId), toJsonDoc(log).toString() ~ "\n");
  }

  override void update(AuditLog log) {
    save(log);
  }

  override void remove(AuditLog log) {
    // Append-only log repository; remove operation intentionally ignored.
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

  private string tenantDir(TenantId tenantId) const {
    return buildPath(basePath, tenantId);
  }

  private string logPath(TenantId tenantId) const {
    return buildPath(tenantDir(tenantId), "audit.ndjson");
  }

  private void ensureTenantDir(TenantId tenantId) @trusted {
    auto dir = tenantDir(tenantId);
    if (!dir.exists) mkdirRecurse(dir);
  }
}
