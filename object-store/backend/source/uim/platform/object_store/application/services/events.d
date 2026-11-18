/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.services.events;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Publishes lifecycle events of the aggregates ("objectstore.bucket.created")
/// on the event publisher (integration / audit).
class EventRecorder {
  protected IObjectStoreEventPublisher publisher;

  this(IObjectStoreEventPublisher publisher) {
    this.publisher = publisher;
  }

  void publish(string topic, Json payload) {
    publisher.publish(topic, payload);
  }
}

/// Publisher that keeps the events in memory (tests, diagnostics).
class MemoryEventPublisher : IObjectStoreEventPublisher {
  string[] topics;
  Json[] payloads;

  void publish(string topic, Json payload) {
    topics ~= topic;
    payloads ~= payload;
  }
}
