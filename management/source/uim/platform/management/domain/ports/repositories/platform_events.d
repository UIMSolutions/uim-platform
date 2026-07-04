/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.platform_events;
// import uim.platform.management.domain.entities.platform_event;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Port: outgoing — platform event persistence.
interface EnvironmentEventRepository : ITenantRepository!(EnvironmentEvent, EnvironmentEventId) {

  EnvironmentEvent[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId);
  EnvironmentEvent[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  EnvironmentEvent[] findByCategory(TenantId tenantId, GlobalAccountId globalAccountId, EnvironmentEventCategory category);
  EnvironmentEvent[] findBySeverity(TenantId tenantId, GlobalAccountId globalAccountId, EnvironmentEventSeverity severity);
  EnvironmentEvent[] findSince(TenantId tenantId, GlobalAccountId globalAccountId, long sinceTimestamp);
  
}
