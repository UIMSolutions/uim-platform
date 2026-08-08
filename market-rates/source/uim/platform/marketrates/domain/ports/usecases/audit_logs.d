/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.domain.ports.usecases.audit_logs;
import uim.platform.marketrates;

mixin(ShowModule!());

@safe:

interface IManageAuditLogsUseCase {

  AuditLog[] listLogs(TenantId tenantId);
  AuditLog[] listLogs(TenantId tenantId, AuditOperation op);
  AuditLog[] listLogs(TenantId tenantId, string providerCode);
  AuditLog[] listLogs(TenantId tenantId, OperationStatus status);
  AuditLog getLog(TenantId tenantId, AuditLogId id);
  
}
