/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.event_channel;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// A documented event channel (topic) of a messaging service, optionally
/// described by an AsyncAPI document.
struct EventChannel {
  mixin TenantEntity!EventChannelId;

  MessagingServiceId serviceId;
  string name;
  string description;
  EventChannelStatus status = EventChannelStatus.active;
  EventChannelType channelType = EventChannelType.topic;
  string topicName; /// concrete topic inside the service namespace
  string asyncapiDefinition; /// AsyncAPI document (JSON or YAML text)
  int retentionHours;
  int partitions = 1;

  void validate() const {
    requireText(name, "Event channel name");
    if (serviceId.isNull)
      throw EventsException.invalid("Event channel needs a serviceId");
    if (!isValidTopic(topicName))
      throw EventsException.invalid("Invalid topic '" ~ topicName ~ "'");
    requireNonNegative(retentionHours, "retentionHours");
    if (partitions < 1)
      throw EventsException.invalid("partitions must be at least 1");
  }
}
