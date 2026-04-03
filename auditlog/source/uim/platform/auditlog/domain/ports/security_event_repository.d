/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.ports.security_event_repository;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.security_event;

import uim.platform.auditlog;

mixin(ShowModule!());

/// Port for persisting enriched security events.
@safe:
interface SecurityEventRepository
{
  bool existsByAuditLogId(AuditLogId auditLogId, TenantId tenantId);
  SecurityEvent findByAuditLogId(AuditLogId auditLogId, TenantId tenantId);

  SecurityEvent[] findByTenant(TenantId tenantId);
  SecurityEvent[] findByUser(TenantId tenantId, UserId userId);
  SecurityEvent[] findByOutcome(TenantId tenantId, AuditOutcome outcome);
  SecurityEvent[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);

  void save(SecurityEvent event);
  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
