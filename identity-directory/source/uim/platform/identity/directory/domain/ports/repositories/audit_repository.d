/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.ports.repositories.audits;

import uim.platform.identity.directory.domain.entities.audit_event;
import uim.platform.identity.directory.domain.types;

/// Port: outgoing — audit event persistence.
interface AuditRepository {
  void save(AuditEvent event);
  AuditEvent[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
  AuditEvent[] findByActor(string actorId, uint offset = 0, uint limit = 100);
  AuditEvent[] findByTarget(string targetId, uint offset = 0, uint limit = 100);
  AuditEvent[] findByType(TenantId tenantId, AuditEventType eventType,
      uint offset = 0, uint limit = 100);
  AuditEvent[] findByTimeRange(TenantId tenantId, long from, long to,
      uint offset = 0, uint limit = 100);
  size_t countByTenant(TenantId tenantId);
}
