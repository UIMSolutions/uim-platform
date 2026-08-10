/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.domain.ports.usecases.audit_logs;
import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

interface IManageAuditLogsUseCase {
  
  AuditLog[] list(TenantId tenantId);
  AuditLog[] listByOperation(TenantId tenantId, AuditOperation op);
  AuditLog[] listByProvider(TenantId tenantId, string providerCode);
  AuditLog[] listByStatus(TenantId tenantId, OperationStatus status);
  AuditLog getById(TenantId tenantId, AuditLogId id);

}
