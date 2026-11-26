/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A delivery channel of a consumer system: a webhook (push: HTTP POST of
/// the CloudEvent) or a queue (pull: the consumer reads and acknowledges).
module uim.platform.application_events.domain.entities.event_channel;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

enum long minChannelBytes = 1024;
enum long maxChannelBytes = 16 * 1024 * 1024;

struct EventChannel {
  mixin TenantEntity!EventChannelId;

  string name;
  string description;
  ChannelType channelType = ChannelType.webhook;
  string endpoint; /// webhook URL (queue: unused)
  SystemRegistrationId consumerSystemId;
  DeliveryMode deliveryMode = DeliveryMode.atLeastOnce;
  ChannelStatus status = ChannelStatus.active;
  long maxSizeBytes = 1_048_576; /// larger payloads go to the dead letters

  bool acceptsMessages() const {
    return status == ChannelStatus.active;
  }

  bool delivers() const {
    return status != ChannelStatus.inactive;
  }

  bool isQueue() const {
    return channelType == ChannelType.queue;
  }

  void validate() const {
    requireId(id.value, "Channel ID");
    requireText(name, "Channel name");
    requireMaxLength(name, 200, "Channel name");
    requireMaxLength(description, 2000, "Description");
    if (consumerSystemId.isNull)
      throw AehException.invalid("The consumer system of the channel is required");
    if (channelType == ChannelType.webhook)
      requireHttpUrl(endpoint, "Webhook endpoint", true);
    requireRange(maxSizeBytes, minChannelBytes, maxChannelBytes, "Maximum message size (bytes)");
  }
}

///
unittest {
  EventChannel c;
  c.id = EventChannelId("crm");
  c.name = "CRM webhook";
  c.consumerSystemId = SystemRegistrationId("crm");
  assert(failsWith(AehErrorKind.invalid, () { c.validate(); }), "a webhook needs an endpoint");
  c.endpoint = "https://crm.example.com/events";
  c.validate();
  c.channelType = ChannelType.queue;
  c.endpoint = "";
  c.validate();
  assert(c.isQueue && c.acceptsMessages && c.delivers);
  c.status = ChannelStatus.draining;
  assert(!c.acceptsMessages && c.delivers);
}
