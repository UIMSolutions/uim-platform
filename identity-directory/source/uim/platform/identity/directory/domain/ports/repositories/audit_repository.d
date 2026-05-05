/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.ports.repositories.audits;

import uim.platform.identity.directory.domain.entities.audit_event;
import uim.platform.identity.directory.domain.types;

/// Port: outgoing — audit event persistence.
interface AuditRepository  : ITenantRepository!(AuditEvent, AuditEventId) {

  size_t countByActor(string actorId);
  AuditEvent[] findByActor(string actorId, size_t offset = 0, size_t limit = 100);
  void removeByActor(string actorId);

  size_t countByTarget(string targetId);
  AuditEvent[] findByTarget(string targetId, size_t offset = 0, size_t limit = 100);
  void removeByTarget(string targetId);

  size_t countByType(TenantId tenantId, AuditEventType eventType);
  AuditEvent[] findByType(TenantId tenantId, AuditEventType eventType, size_t offset = 0, size_t limit = 100);
  void removeByType(TenantId tenantId, AuditEventType eventType);
  
}
