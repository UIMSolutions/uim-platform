module uim.platform.management.application.helpers;

import uim.platform.management;

mixin(ShowModule!());

@safe:
void emitEvent(PlatformEventRepository eventRepo, string gaId, string subId, PlatformEventCategory cat,
  string eventType, string desc, string initiatedBy) {
  emitEvent(eventRepo, GlobalAccountId(gaId), SubaccountId(subId), cat, eventType, desc, initiatedBy);
}

void emitEvent(PlatformEventRepository eventRepo,GlobalAccountId gaId, SubaccountId subId, PlatformEventCategory cat,
  string eventType, string desc, string initiatedBy, string sourceService = "cloud-management") {
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
  event.sourceService = sourceService;
  event.timestamp = clockSeconds();
  eventRepo.save(event);
}
