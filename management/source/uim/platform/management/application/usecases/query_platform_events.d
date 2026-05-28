/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.query_platform_events;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.ports.repositories.platform_events;
// import uim.platform.management.domain.types;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: query platform events for audit and monitoring.
class QueryPlatformEventsUseCase { // TODO: UIMUseCase {
  private PlatformEventRepository repo;

  this(PlatformEventRepository repo) {
    this.repo = repo;
  }

  PlatformEvent getEvent(TenantId tenantId, PlatformEventId id) {
    return repo.findById(tenantId, id);
  }

  PlatformEvent[] listEvents(TenantId tenantId, GlobalAccountId gaId) {
    return repo.findByGlobalAccount(tenantId, gaId);
  }

  PlatformEvent[] listEvents(TenantId tenantId, SubaccountId subId) {
    return repo.findBySubaccount(tenantId, subId);
  }

  PlatformEvent[] listEvents(TenantId tenantId, GlobalAccountId gaId, PlatformEventCategory category) {
    return repo.findByCategory(tenantId, gaId, category);
  }

  PlatformEvent[] listEvents(TenantId tenantId, GlobalAccountId gaId, PlatformEventSeverity severity) {
    return repo.findBySeverity(tenantId, gaId, severity);
  }

  PlatformEvent[] listSince(TenantId tenantId, GlobalAccountId gaId, long sinceTimestamp) {
    return repo.findSince(tenantId, gaId, sinceTimestamp);
  }

  private PlatformEventCategory parseCategory(string category) {
    switch (category) {
    case "subaccountLifecycle":
      return PlatformEventCategory.subaccountLifecycle;
    case "entitlementChange":
      return PlatformEventCategory.entitlementChange;
    case "environmentLifecycle":
      return PlatformEventCategory.environmentLifecycle;
    case "subscriptionLifecycle":
      return PlatformEventCategory.subscriptionLifecycle;
    case "directoryChange":
      return PlatformEventCategory.directoryChange;
    case "globalAccountChange":
      return PlatformEventCategory.globalAccountChange;
    case "quotaChange":
      return PlatformEventCategory.quotaChange;
    case "securityEvent":
      return PlatformEventCategory.securityEvent;
    default:
      return PlatformEventCategory.subaccountLifecycle;
    }
  }

  private PlatformEventSeverity parseSeverity(string severity) {
    switch (severity) {
    case "info":
      return PlatformEventSeverity.info;
    case "warning":
      return PlatformEventSeverity.warning;
    case "error":
      return PlatformEventSeverity.error;
    case "critical":
      return PlatformEventSeverity.critical;
    default:
      return PlatformEventSeverity.info;
    }
  }
}
