/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.entities.message_binding;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// Grants a message client access to exactly one queue or event channel.
struct MessageBinding {
  mixin TenantEntity!MessageBindingId;

  MessageClientId clientId;
  MessagingServiceId serviceId; /// derived from the client
  QueueId queueId; /// either queueId ...
  EventChannelId channelId; /// ... or channelId
  string name;
  string description;
  MessageBindingStatus status = MessageBindingStatus.active;
  MessageBindingPermission permission = MessageBindingPermission.publishSubscribe;

  bool isActive() const {
    return status == MessageBindingStatus.active;
  }

  void validate() const {
    if (clientId.isNull)
      throw EventsException.invalid("Message binding needs a clientId");
    if (queueId.isNull == channelId.isNull)
      throw EventsException.invalid("Message binding needs exactly one of queueId or channelId");
  }
}

///
unittest {
  MessageBinding b;
  b.clientId = MessageClientId("c");
  assert(failsWith(EventsErrorKind.invalid, () { b.validate(); }));
  b.queueId = QueueId("q");
  b.validate();
  b.channelId = EventChannelId("ch");
  assert(failsWith(EventsErrorKind.invalid, () { b.validate(); }));
}
