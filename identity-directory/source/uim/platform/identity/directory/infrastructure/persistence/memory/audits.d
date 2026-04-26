/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.infrastructure.persistence.memory.audits;

// import uim.platform.identity.directory.domain.entities.audit_event;
// import uim.platform.identity.directory.domain.types;
// import uim.platform.identity.directory.domain.ports.repositories.audits;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// In-memory adapter for audit event persistence (append-only).
class MemoryAuditRepository : TenantRepository!(AuditEvent, AuditEventId), AuditRepository {

  AuditEvent[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100) {
    return filterPaged((AuditEvent e) => e.tenantId == tenantId, offset, limit);
  }

  size_t countByActor(string actorId) {
    return findByActor(actorId).length;
  }
  AuditEvent[] filterByActor(AuditEvent[] events, string actorId) {
    return events.filter!(e => e.actorId == actorId).array;
  }
  AuditEvent[] findByActor(string actorId) {
    return filterByActor(findAll(), actorId);
  }
  void removeByActor(string actorId) {
    findByActor(actorId).each!(e => remove(e));
  }

  size_t countByTarget(string targetId) {
    return findByTarget(targetId).length;
  }
  AuditEvent[] filterByTarget(AuditEvent[] events, string targetId) {
    return events.filter!(e => e.targetId == targetId).array;
  }
  AuditEvent[] findByTarget(string targetId) {
    return filterByTarget(findAll(), targetId);
  }
  void removeByTarget(string targetId) {
    findByTarget(targetId).each!(e => remove(e));
  }

  size_t countByType(TenantId tenantId, AuditEventType eventType) {
    return findByType(tenantId, eventType).length;
  }
  AuditEvent[] filterByType(AuditEvent[] events, TenantId tenantId, AuditEventType eventType) {
    return events.filter!(e => e.tenantId == tenantId && e.eventType == eventType).array;
  }
  AuditEvent[] findByType(TenantId tenantId, AuditEventType eventType) {
    return filterByType(findAll(), tenantId, eventType);
  }
  void removeByType(TenantId tenantId, AuditEventType eventType) {
    findByType(tenantId, eventType).each!(e => remove(e));
  }

  size_t countByTimeRange(TenantId tenantId, long from, long to) {
    return findByTimeRange(tenantId, from, to).length;
  }
  AuditEvent[] filterByTimeRange(AuditEvent[] events, long from, long to) {
    return events.filter!(e => e.timestamp >= from && e.timestamp <= to).array;
  }
  AuditEvent[] findByTimeRange(TenantId tenantId, long from, long to) {
    return filterByTimeRange(findByTenant(tenantId), from, to);
  }
  void removeByTimeRange(TenantId tenantId, long from, long to) {
    findByTimeRange(tenantId, from, to).each!(e => remove(e));
  }


  
}
