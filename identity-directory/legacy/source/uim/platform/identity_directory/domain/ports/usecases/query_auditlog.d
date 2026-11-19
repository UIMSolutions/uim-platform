/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.domain.ports.usecases.query_auditlog;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// Application use case: query audit logs.
interface IQueryAuditLogUseCase {

  /// List audit events by tenant.
  AuditEvent[] listEvents(TenantId tenantId);
  
  /// Find events by actor.
  AuditEvent[] findByActor(TenantId tenantId, string actorId);

  /// Find events by target resource.
  AuditEvent[] findByTarget(TenantId tenantId, string targetId);

  /// Find events by type.
  AuditEvent[] findByType(TenantId tenantId, AuditEventType eventType);

  /// Find events within a time range.
  AuditEvent[] findByTimeRange(TenantId tenantId, long from, long to);
}
