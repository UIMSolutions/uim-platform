module uim.platform.management.application.helpers;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
void emitEvent(EnvironmentEventRepository eventRepo, string gaId, string subId, EnvironmentEventCategory cat,
  string eventType, string desc, UserId initiatedBy) {
  emitEvent(eventRepo, GlobalAccountId(gaId), SubaccountId(subId), cat, eventType, desc, initiatedBy);
}

void emitEvent(EnvironmentEventRepository eventRepo,GlobalAccountId gaId, SubaccountId subId, EnvironmentEventCategory cat,
  string eventType, string desc, UserId initiatedBy, string sourceService = "cloud-management") {

  auto event = EnvironmentEvent(); 
  
  event.globalAccountId = gaId;
  event.subaccountId = subId;
  event.category = cat;
  event.severity = EnvironmentEventSeverity.info;
  event.eventType = eventType;
  event.description = desc;
  event.initiatedBy = initiatedBy;
  event.sourceService = sourceService;
  event.timestamp = event.createdAt;

  eventRepo.save(event);
}
