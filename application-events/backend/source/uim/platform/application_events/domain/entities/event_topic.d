/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An event type of the catalog, e.g.
/// "sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1". Producers
/// may only publish registered, not retired types (requireRegisteredTopics).
module uim.platform.application_events.domain.entities.event_topic;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

struct EventTopic {
  mixin TenantEntity!EventTopicId;

  string eventType; /// unique, cannot change
  string title;
  string description;
  string category; /// e.g. "Business Partner"
  string version_ = "1.0.0"; /// version of the payload schema
  SystemRegistrationId ownerSystemId; /// the producing system ("" = any)
  TopicStatus status = TopicStatus.active;

  bool acceptsEvents() const {
    return status != TopicStatus.retired;
  }

  void validate() const {
    requireId(id.value, "Event type ID");
    requireEventType(eventType);
    requireMaxLength(title, 200, "Title");
    requireMaxLength(description, 4000, "Description");
    requireMaxLength(category, 200, "Category");
    requireText(version_, "Version");
    requireMaxLength(version_, 40, "Version");
  }
}

///
unittest {
  EventTopic t;
  t.id = EventTopicId("bp-created");
  t.eventType = "sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1";
  t.validate();
  assert(t.acceptsEvents);
  t.status = TopicStatus.retired;
  assert(!t.acceptsEvents);
  t.eventType = "sap.*";
  assert(failsWith(AehErrorKind.invalid, () { t.validate(); }), "no wildcards in the catalog");
}
