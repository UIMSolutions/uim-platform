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
class QueryPlatformEventsUseCase : UIMUseCase {
  private PlatformEventRepository repo;

  this(PlatformEventRepository repo) {
    this.repo = repo;
  }

  PlatformEvent getById(PlatformEventId id) {
    return repo.findById(id);
  }

  PlatformEvent[] listByGlobalAccount(string gaId) {
    return listByGlobalAccount(GlobalAccountId(gaId));
  }

  PlatformEvent[] listByGlobalAccount(GlobalAccountId gaId) {
    return repo.findByGlobalAccount(gaId);
  }

  PlatformEvent[] listBySubaccount(string subId) {
    return listBySubaccount(SubaccountId(subId));
  }

  PlatformEvent[] listBySubaccount(SubaccountId subId) {
    return repo.findBySubaccount(subId);
  }

  PlatformEvent[] listByCategory(string gaId, string category) {
    return listByCategory(GlobalAccountId(gaId), category);
  }

  PlatformEvent[] listByCategory(GlobalAccountId gaId, string category) {
    return repo.findByCategory(gaId, parseCategory(category));
  }

  PlatformEvent[] listBySeverity(string gaId, string severity) {
    return listBySeverity(GlobalAccountId(gaId), severity);
  }

  PlatformEvent[] listBySeverity(GlobalAccountId gaId, string severity) {
    return repo.findBySeverity(gaId, parseSeverity(severity));
  }

  PlatformEvent[] listSince(GlobalAccountId gaId, long sinceTimestamp) {
    return repo.findSince(gaId, sinceTimestamp);
  }

  private PlatformEventCategory parseCategory(string s) {
    switch (s) {
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

  private PlatformEventSeverity parseSeverity(string s) {
    switch (s) {
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
