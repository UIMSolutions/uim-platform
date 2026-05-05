/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.application.usecases.query_audit_log;

// import uim.platform.identity.directory.domain.entities.audit_event;
// import uim.platform.identity.directory.domain.types;
// import uim.platform.identity.directory.domain.ports.repositories.audits;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// Application use case: query audit logs.
class QueryAuditLogUseCase { // TODO: UIMUseCase {
  private AuditRepository auditRepo;

  this(AuditRepository auditRepo) {
    this.auditRepo = auditRepo;
  }

  /// List audit events by tenant.
  AuditEvent[] listEvents(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return auditRepo.findByTenant(tenantId, offset, limit);
  }

  /// Find events by actor.
  AuditEvent[] findByActor(string actorId, size_t offset = 0, size_t limit = 100) {
    return auditRepo.findByActor(actorId, offset, limit);
  }

  /// Find events by target resource.
  AuditEvent[] findByTarget(string targetId, size_t offset = 0, size_t limit = 100) {
    return auditRepo.findByTarget(targetId, offset, limit);
  }

  /// Find events by type.
  AuditEvent[] findByType(TenantId tenantId, AuditEventType eventType,
      size_t offset = 0, size_t limit = 100) {
    return auditRepo.findByType(tenantId, eventType, offset, limit);
  }

  /// Find events within a time range.
  AuditEvent[] findByTimeRange(TenantId tenantId, long from, long to,
      size_t offset = 0, size_t limit = 100) {
    return auditRepo.findByTimeRange(tenantId, from, to, offset, limit);
  }
}
