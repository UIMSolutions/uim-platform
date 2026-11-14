/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Records platform events (audit trail of all management operations).
module uim.platform.management.application.services.event_recorder;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Where an event happened.
struct EventScope {
  GlobalAccountId globalAccountId;
  SubaccountId subaccountId;
  DirectoryId directoryId;
  string resourceType;
  string resourceId;
}

/// Application service: persists platform events and publishes them.
/// Every use case that changes state reports through this recorder.
class PlatformEventRecorder {
  protected IEnvironmentEventRepository events;
  protected IPlatformEventPublisher publisher;
  protected string sourceService;

  this(IEnvironmentEventRepository events, IPlatformEventPublisher publisher, string sourceService = "cloud-management") {
    this.events = events;
    this.publisher = publisher;
    this.sourceService = sourceService;
  }

  EnvironmentEvent record(TenantId tenantId, EventScope where, EnvironmentEventCategory category,
      string eventType, string description, UserId initiatedBy,
      EnvironmentEventSeverity severity = EnvironmentEventSeverity.info, string[string] details = null) {
    auto event = EnvironmentEvent(tenantId);
    event.globalAccountId = where.globalAccountId;
    event.subaccountId = where.subaccountId;
    event.directoryId = where.directoryId;
    event.resourceType = where.resourceType;
    event.resourceId = where.resourceId;
    event.category = category;
    event.severity = severity;
    event.eventType = eventType;
    event.description = description;
    event.initiatedBy = actor(initiatedBy);
    event.createdBy = event.initiatedBy;
    event.updatedBy = event.initiatedBy;
    event.sourceService = sourceService;
    event.timestamp = event.createdAt;
    event.details = details;
    events.save(event);

    if (publisher !is null) {
      try
        publisher.publish("management/" ~ eventType.replace(".", "/"), event.toJson);
      catch (Exception e)
        logWarn("management: cannot publish event %s: %s", eventType, e.msg);
    }
    return event;
  }

  // ── convenience: scopes per resource ───────────────────────────────────

  static EventScope ofGlobalAccount(const GlobalAccount ga) {
    return EventScope(ga.id, SubaccountId.init, DirectoryId.init, "globalAccount", ga.id.value);
  }

  static EventScope ofDirectory(const AccountDirectory d) {
    return EventScope(d.globalAccountId, SubaccountId.init, d.id, "directory", d.id.value);
  }

  static EventScope ofSubaccount(const Subaccount s) {
    return EventScope(s.globalAccountId, s.id, s.parentDirectoryId, "subaccount", s.id.value);
  }

  static EventScope ofEntitlement(const Entitlement e) {
    return EventScope(e.globalAccountId, e.subaccountId, e.directoryId, "entitlement", e.id.value);
  }

  static EventScope ofEnvironment(const Environment e) {
    return EventScope(e.globalAccountId, e.subaccountId, DirectoryId.init, "environment", e.id.value);
  }

  static EventScope ofSubscription(const Subscription s) {
    return EventScope(s.globalAccountId, s.subaccountId, DirectoryId.init, "subscription", s.id.value);
  }
}
