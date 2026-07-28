/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.infrastructure.persistence.repositories.audit_logs;
import uim.platform.marketrates;
import std.algorithm : filter;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryAuditLogRepository : TenantRepository!(AuditLog, AuditLogId), AuditLogRepository {

  size_t countByOperation(TenantId tenantId, AuditOperation op) {
    return findByOperation(tenantId, op).length;
  }

  AuditLog[] filterByOperation(AuditLog[] logs, AuditOperation op) {
    return logs.filter!(l => l.operation == op).array;
  }

  AuditLog[] findByDateRange(TenantId tenantId, string from_, string to_) {
    return filterByDateRange(findByTenant(tenantId).array, from_, to_);
  }

  size_t countByProvider(TenantId tenantId, string code) {
    return findByProvider(tenantId, code).length;
  }

  AuditLog[] filterByProvider(AuditLog[] logs, string code) {
    return logs.filter!(l => l.providerCode == code).array;
  }

  AuditLog[] findByProvider(TenantId tenantId, string code) {
    return filterByProvider(findByTenant(tenantId).array, code);
  }

  void removeByProvider(TenantId tenantId, string code) {
    findByProvider(tenantId, code).each!(l => remove(l));
  }

  size_t countByStatus(TenantId tenantId, OperationStatus status) {
    return findByStatus(tenantId, status).length;
  }

  AuditLog[] filterByStatus(AuditLog[] logs, OperationStatus s) {
    return logs.filter!(l => l.status == s).array;
  }

  AuditLog[] findByStatus(TenantId tenantId, OperationStatus status) {
    return filterByStatus(findByTenant(tenantId).array, status);
  }

  void removeByStatus(TenantId tenantId, OperationStatus status) {
    findByStatus(tenantId, status).each!(l => remove(l));
  }

  size_t countByDateRange(TenantId tenantId, string from_, string to_) {
    return findByDateRange(tenantId, from_, to_).length;
  }

  AuditLog[] filterByDateRange(AuditLog[] logs, string from_, string to_) {
    return logs.filter!(l =>
        l.fromDate >= from_ &&
        (to_.length == 0 || l.toDate <= to_)
    ).array;
  }

  AuditLog[] findByDateRange(TenantId tenantId, string from_, string to_) {
    return filterByDateRange(findByTenant(tenantId).array, from_, to_);
  }

  void removeByDateRange(TenantId tenantId, string from_, string to_) {
    findByDateRange(tenantId, from_, to_).each!(l => remove(l));
  }
}
