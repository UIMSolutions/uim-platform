module uim.platform.management.application.helpers;

import uim.platform.management;

mixin(ShowModule!());

@safe:
void emitEvent(PlatformEventRepository eventRepo, string gaId, string subId, PlatformEventCategory cat,
  string eventType, string desc, UserId initiatedBy) {
  emitEvent(eventRepo, GlobalAccountId(gaId), SubaccountId(subId), cat, eventType, desc, initiatedBy);
}

void emitEvent(PlatformEventRepository eventRepo,GlobalAccountId gaId, SubaccountId subId, PlatformEventCategory cat,
  string eventType, string desc, UserId initiatedBy, string sourceService = "cloud-management") {
 

  PlatformEvent event;
  event.initEntity(gaId, subId, initiatedBy);
  
  event.globalAccountId = gaId;
  event.subaccountId = subId;
  event.category = cat;
  event.severity = PlatformEventSeverity.info;
  event.eventType = eventType;
  event.description = desc;
  event.initiatedBy = initiatedBy;
  event.sourceService = sourceService;
  event.timestamp = event.createdAt;

  eventRepo.save(event);
}
