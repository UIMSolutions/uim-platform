module uim.platform.management.application.helpers;

import uim.platform.management;

mixin(ShowModule!());

@safe:
  void emitEvent(string gaId, string subId, PlatformEventCategory cat,
    string eventType, string desc, string initiatedBy) {
    emitEvent(GlobalAccountId(gaId), SubaccountId(subId), cat, eventType, desc, initiatedBy);
  }

  void emitEvent(GlobalAccountId gaId, SubaccountId subId, PlatformEventCategory cat,
    string eventType, string desc, string initiatedBy) {
    // import std.uuid : randomUUID;

    PlatformEvent event;
    event.id = randomUUID();
    event.globalAccountId = gaId;
    event.subaccountId = subId;
    event.category = cat;
    event.severity = PlatformEventSeverity.info;
    event.eventType = eventType;
    event.description = desc;
    event.initiatedBy = initiatedBy;
    event.sourceService = "cloud-management";
    event.timestamp = clockSeconds();
    eventRepo.save(event);
  }