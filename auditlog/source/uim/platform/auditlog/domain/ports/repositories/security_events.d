/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.ports.repositories.security_events;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.security_event;

import uim.platform.auditlog;

mixin(ShowModule!());

/// Port for persisting enriched security events.
@safe:
interface SecurityEventRepository : ITenantRepository!(SecurityEvent, SecurityEventId) {

  size_t countByUser(TenantId tenantId, UserId userId);
  SecurityEvent[] findByUser(TenantId tenantId, UserId userId);
  void removeByUser(TenantId tenantId, UserId userId);

  size_t countByOutcome(TenantId tenantId, AuditOutcome outcome);
  SecurityEvent[] findByOutcome(TenantId tenantId, AuditOutcome outcome);
  void removeByOutcome(TenantId tenantId, AuditOutcome outcome);

  size_t countByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
  SecurityEvent[] findByTimeRange(TenantId tenantId, long timeFrom, long timeTo);
  void removeByTimeRange(TenantId tenantId, long timeFrom, long timeTo);

  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
