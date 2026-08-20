/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.domain.ports.usecases.audit_logs;

import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

/// Port: outgoing — audit log management use case.
interface IManageAuditLogsUseCase {
  
  /// Lists all audit logs for a given tenant.
  /// @param tenantId The tenant ID.
  AuditLog[] list(TenantId tenantId);

  /// Lists all audit logs for a given tenant and operation type.
  /// @param tenantId The tenant ID.
  /// @param op The operation type to filter by.
  AuditLog[] listByOperation(TenantId tenantId, AuditOperation op);

  /// Lists all audit logs for a given tenant and provider code.
  /// @param tenantId The tenant ID.
  /// @param providerCode The provider code to filter by.
  AuditLog[] listByProvider(TenantId tenantId, string providerCode);

  /// Lists all audit logs for a given tenant and operation status.
  /// @param tenantId The tenant ID.
  /// @param status The operation status to filter by.
  AuditLog[] listByStatus(TenantId tenantId, OperationStatus status);

  /// Retrieves an audit log by its ID for a given tenant.
  /// @param tenantId The tenant ID.
  /// @param id The ID of the audit log to retrieve.    
  AuditLog getById(TenantId tenantId, AuditLogId id);

}
