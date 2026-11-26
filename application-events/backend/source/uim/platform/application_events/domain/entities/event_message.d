/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A message: one event routed to one subscription — the unit of delivery
/// with its attempts, back-off and outcome.
module uim.platform.application_events.domain.entities.event_message;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

struct EventMessage {
  mixin TenantEntity!EventMessageId;

  EventSubscriptionId subscriptionId;
  EventChannelId channelId;
  SystemRegistrationId producerSystemId;
  SystemRegistrationId consumerSystemId;
  string eventId; /// CloudEvents id (shared by all messages of one event)
  string eventType;
  string subject;
  string payload; /// JSON text of "data"
  string contentType = "application/json";
  long eventTime; /// CloudEvents time (std time)
  long sizeBytes;
  MessageStatus status = MessageStatus.pending;
  int attempts;
  int maxAttempts = 6; /// first attempt + retries of the subscription
  long nextAttemptAt; /// retrying: earliest next attempt
  long lastAttemptAt;
  string lastError;
  long deliveredAt;

  bool isOpen() const {
    return status.isOpen;
  }

  /// Due for an attempt by the worker at the given time.
  bool isDueAt(long now) const {
    return status == MessageStatus.pending || (status == MessageStatus.retrying && nextAttemptAt <= now);
  }

  /// The CloudEvent sent to the consumer.
  CloudEvent toCloudEvent() const @trusted {
    CloudEvent e;
    e.id = eventId;
    e.type = eventType;
    e.source = producerSystemId.value;
    e.subject = subject;
    e.time = eventTime;
    e.dataContentType = contentType;
    if (payload.length) {
      try
        e.data = parseJsonString(payload);
      catch (Exception)
        e.data = Json(payload);
    }
    return e;
  }
}

///
unittest {
  EventMessage m;
  m.eventId = "e1";
  m.eventType = "a.b";
  m.producerSystemId = SystemRegistrationId("s4");
  m.payload = `{"x":1}`;
  assert(m.isDueAt(0) && m.isOpen);
  m.status = MessageStatus.retrying;
  m.nextAttemptAt = 100;
  assert(!m.isDueAt(99) && m.isDueAt(100));
  auto e = m.toCloudEvent();
  assert(e.source == "s4" && e.data["x"].get!long == 1);
}
