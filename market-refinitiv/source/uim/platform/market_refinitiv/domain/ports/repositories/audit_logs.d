/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.domain.ports.repositories.audit_logs;
import uim.platform.market_refinitiv;

// mixin(ShowModule!());

@safe:
interface AuditLogRepository : ITenantRepository!(AuditLog, AuditLogId) {

  AuditLog[] findByOperation(TenantId tenantId, AuditOperation op);
  AuditLog[] findByProvider(TenantId tenantId, string providerCode);
  AuditLog[] findByStatus(TenantId tenantId, OperationStatus status);
  AuditLog[] findByDateRange(TenantId tenantId, string fromDate, string toDate);
}
