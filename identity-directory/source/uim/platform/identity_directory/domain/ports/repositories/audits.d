/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.domain.ports.repositories.audits;

// import uim.platform.identity_directory.domain.entities.audit_event;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// Port: outgoing — audit event persistence.
interface AuditRepository : ITenantRepository!(AuditEvent, AuditEventId) {

  size_t countByActor(TenantId tenantId, string actorId);
  AuditEvent[] findByActor(TenantId tenantId, string actorId); //, size_t offset = 0, size_t limit = 100);
  void removeByActor(TenantId tenantId, string actorId);

  size_t countByTarget(TenantId tenantId, string targetId);
  AuditEvent[] findByTarget(TenantId tenantId, string targetId); //, size_t offset = 0, size_t limit = 100);
  void removeByTarget(TenantId tenantId, string targetId);

  size_t countByType(TenantId tenantId, AuditEventType eventType);
  AuditEvent[] findByType(TenantId tenantId, AuditEventType eventType); //, size_t offset = 0, size_t limit = 100);
  void removeByType(TenantId tenantId, AuditEventType eventType);

  size_t countByTimeRange(TenantId tenantId, long from, long to);
  AuditEvent[] filterByTimeRange(AuditEvent[] events, long from, long to);
  AuditEvent[] findByTimeRange(TenantId tenantId, long from, long to);
  void removeByTimeRange(TenantId tenantId, long from, long to);
  
}
