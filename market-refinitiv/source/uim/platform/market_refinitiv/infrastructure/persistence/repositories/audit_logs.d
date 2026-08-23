/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.infrastructure.persistence.repositories.audit_logs;
import uim.platform.market_refinitiv;
import std.algorithm : filter;
import std.array : array;

mixin(ShowModule!());

@safe:

class AuditLogRepository : TenantRepository!(AuditLog, AuditLogId), IAuditLogRepository {

  size_t countByOperation(TenantId tenantId, AuditOperation op) {
    return findByTenant(tenantId).filter!(l => l.operation == op).length;
  }

  AuditLog[] filterByOperation(AuditLog[] logs, AuditOperation op) {
    return logs.filter!(l => l.operation == op).array;
  }

  AuditLog[] findByOperation(TenantId tenantId, AuditOperation op) {
    return filterByOperation(findByTenant(tenantId), op);
  }

  size_t countByProvider(TenantId tenantId, string code) {
    return findByTenant(tenantId).filter!(l => l.providerCode == code).length;
  }

AuditLog[] filterByProvider(AuditLog[] logs, string code) {
    return logs.filter!(l => l.providerCode == code).array;
  }
  
  AuditLog[] findByProvider(TenantId tenantId, string code) {
    return filterByProvider(findByTenant(tenantId), code);
  }

  size_t countByStatus(TenantId tenantId, OperationStatus s) {
    return findByTenant(tenantId).filter!(l => l.status == s).length;
  }

  AuditLog[] filterByStatus(AuditLog[] logs, OperationStatus s) {
    return logs.filter!(l => l.status == s).array;
  }

  AuditLog[] findByStatus(TenantId tenantId, OperationStatus s) {
    return filterByStatus(findByTenant(tenantId), s);
  }

  size_t countByDateRange(TenantId tenantId, string from_, string to_) {
    return findByTenant(tenantId).filter!(l =>
        l.fromDate >= from_ &&
        (to_.length == 0 || l.toDate <= to_)
    ).array.length;
  }

  AuditLog[] findByDateRange(TenantId tenantId, string from_, string to_) {
    return findByTenant(tenantId).filter!(l =>
        l.fromDate >= from_ &&
        (to_.length == 0 || l.toDate <= to_)
    ).array;
  }
}