/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.query_platform_events;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.ports.repositories.platform_events;


import uim.platform.management;

// mixin(ShowModule!());

@safe:
/// Use case: query platform events for audit and monitoring.
class QueryEnvironmentEventsUseCase { // TODO: UIMUseCase {
  private EnvironmentEventRepository repo;

  this(EnvironmentEventRepository repo) {
    this.repo = repo;
  }

  EnvironmentEvent getEvent(TenantId tenantId, EnvironmentEventId id) {
    return repo.find(tenantId, id);
  }

  EnvironmentEvent[] listEvents(TenantId tenantId, GlobalAccountId gaId) {
    return repo.findByGlobalAccount(tenantId, gaId);
  }

  EnvironmentEvent[] listEvents(TenantId tenantId, SubaccountId subId) {
    return repo.findBySubaccount(tenantId, subId);
  }

  EnvironmentEvent[] listEvents(TenantId tenantId, GlobalAccountId gaId, EnvironmentEventCategory category) {
    return repo.findByCategory(tenantId, gaId, category);
  }

  EnvironmentEvent[] listEvents(TenantId tenantId, GlobalAccountId gaId, EnvironmentEventSeverity severity) {
    return repo.findBySeverity(tenantId, gaId, severity);
  }

  EnvironmentEvent[] listSince(TenantId tenantId, GlobalAccountId gaId, long sinceTimestamp) {
    return repo.findSince(tenantId, gaId, sinceTimestamp);
  }

  private EnvironmentEventCategory parseCategory(string category) {
    switch (category) {
    case "subaccountLifecycle":
      return EnvironmentEventCategory.subaccountLifecycle;
    case "entitlementChange":
      return EnvironmentEventCategory.entitlementChange;
    case "environmentLifecycle":
      return EnvironmentEventCategory.environmentLifecycle;
    case "subscriptionLifecycle":
      return EnvironmentEventCategory.subscriptionLifecycle;
    case "directoryChange":
      return EnvironmentEventCategory.directoryChange;
    case "globalAccountChange":
      return EnvironmentEventCategory.globalAccountChange;
    case "quotaChange":
      return EnvironmentEventCategory.quotaChange;
    case "securityEvent":
      return EnvironmentEventCategory.securityEvent;
    default:
      return EnvironmentEventCategory.subaccountLifecycle;
    }
  }

  private EnvironmentEventSeverity parseSeverity(string severity) {
    switch (severity) {
    case "info":
      return EnvironmentEventSeverity.info;
    case "warning":
      return EnvironmentEventSeverity.warning;
    case "error":
      return EnvironmentEventSeverity.error;
    case "critical":
      return EnvironmentEventSeverity.critical;
    default:
      return EnvironmentEventSeverity.info;
    }
  }
}
