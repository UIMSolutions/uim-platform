/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A subscription routes the events of a producer system whose type
/// matches a pattern (exact type or wildcards, see event_types) to a
/// channel of a consumer system. Filters narrow the routed events.
module uim.platform.application_events.domain.entities.event_subscription;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

enum int maxRetriesLimit = 20;
enum int minBackoffSeconds = 1;
enum int maxBackoffSeconds = 3600;

struct EventSubscription {
  mixin TenantEntity!EventSubscriptionId;

  string name;
  string description;
  SystemRegistrationId producerSystemId;
  SystemRegistrationId consumerSystemId;
  string eventType; /// type or pattern ("sap.s4.beh.businesspartner.v1.*")
  EventChannelId channelId;
  FormationId formationId; /// the formation of both systems (derived)
  SubscriptionStatus status = SubscriptionStatus.active;
  int maxRetries = 5; /// retries after the first attempt (at-least-once)
  int retryBackoffSeconds = 30; /// first back-off; doubles per attempt
  long lastMatchedAt; /// std time of the last routed event

  bool isActive() const {
    return status == SubscriptionStatus.active;
  }

  bool matches(string type) const {
    return matchesEventType(eventType, type);
  }

  void validate() const {
    requireId(id.value, "Subscription ID");
    requireText(name, "Subscription name");
    requireMaxLength(name, 200, "Subscription name");
    requireMaxLength(description, 2000, "Description");
    if (producerSystemId.isNull)
      throw AehException.invalid("The producer system is required");
    if (consumerSystemId.isNull)
      throw AehException.invalid("The consumer system is required");
    if (channelId.isNull)
      throw AehException.invalid("The channel is required");
    requireEventTypePattern(eventType);
    requireRange(maxRetries, 0, maxRetriesLimit, "Maximum retries");
    requireRange(retryBackoffSeconds, minBackoffSeconds, maxBackoffSeconds, "Retry back-off (seconds)");
  }
}

///
unittest {
  EventSubscription s;
  s.id = EventSubscriptionId("bp");
  s.name = "BP to CRM";
  s.producerSystemId = SystemRegistrationId("s4");
  s.consumerSystemId = SystemRegistrationId("crm");
  s.channelId = EventChannelId("crm");
  s.eventType = "sap.s4.beh.businesspartner.v1.*";
  s.validate();
  assert(s.matches("sap.s4.beh.businesspartner.v1.BusinessPartner.Changed.v1") && !s.matches("sap.s4.beh.salesorder.v1.X"));
  s.maxRetries = 99;
  assert(failsWith(AehErrorKind.invalid, () { s.validate(); }));
}
