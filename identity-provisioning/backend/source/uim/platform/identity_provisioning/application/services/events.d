/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.services.events;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Publishes lifecycle events of the aggregates ("provisioning.job.created")
/// on the event publisher (integration / audit).
class EventRecorder {
  protected IProvisioningEventPublisher publisher;

  this(IProvisioningEventPublisher publisher) {
    this.publisher = publisher;
  }

  void publish(string topic, Json payload) {
    publisher.publish(topic, payload);
  }
}

/// Publisher that keeps the events in memory (tests, diagnostics).
class MemoryEventPublisher : IProvisioningEventPublisher {
  string[] topics;
  Json[] payloads;

  void publish(string topic, Json payload) {
    topics ~= topic;
    payloads ~= payload;
  }
}
