/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.platform_events;
// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Port: outgoing — platform event persistence.
interface PlatformEventRepository : ITenantRepository!(PlatformEvent, PlatformEventId) {

  PlatformEvent[] findByGlobalAccount(TenantId tenantId, GlobalAccountId globalAccountId);
  PlatformEvent[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  PlatformEvent[] findByCategory(TenantId tenantId, GlobalAccountId globalAccountId, PlatformEventCategory category);
  PlatformEvent[] findBySeverity(TenantId tenantId, GlobalAccountId globalAccountId, PlatformEventSeverity severity);
  PlatformEvent[] findSince(TenantId tenantId, GlobalAccountId globalAccountId, long sinceTimestamp);
  
}
