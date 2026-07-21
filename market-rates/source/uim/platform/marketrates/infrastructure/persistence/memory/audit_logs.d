/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.infrastructure.persistence.repositories.audit_logs;
import uim.platform.marketrates;
import std.algorithm : filter;
import std.array     : array;

mixin(ShowModule!());

@safe:

class MemoryAuditLogRepository : AuditLogRepository {
  private AuditLog[string] store;

  override AuditLog   findById(TenantId t, AuditLogId id) {
    if (auto p = id.value in store) return *p;
    AuditLog empty; return empty;
  }
  override AuditLog[] findByTenant(TenantId t) {
    return store.values.filter!(l => l.tenantId == t).array;
  }
  override void save(AuditLog l)   { store[l.id.value] = l; }
  override void update(AuditLog l) { store[l.id.value] = l; }
  override void remove(AuditLog l) { store.remove(l.id.value); }

  override AuditLog[] findByOperation(TenantId t, AuditOperation op) {
    return store.values.filter!(l => l.tenantId == t && l.operation == op).array;
  }
  override AuditLog[] findByProvider(TenantId t, string code) {
    return store.values.filter!(l => l.tenantId == t && l.providerCode == code).array;
  }
  override AuditLog[] findByStatus(TenantId t, OperationStatus s) {
    return store.values.filter!(l => l.tenantId == t && l.status == s).array;
  }
  override AuditLog[] findByDateRange(TenantId t, string from_, string to_) {
    return store.values.filter!(l =>
      l.tenantId == t &&
      l.fromDate >= from_ &&
      (to_.length == 0 || l.toDate <= to_)
    ).array;
  }
}
