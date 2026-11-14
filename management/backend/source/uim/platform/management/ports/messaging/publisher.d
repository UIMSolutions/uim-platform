/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.ports.messaging.publisher;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Driven port: publishes platform events to a message broker
/// (SAP Event Mesh, Kafka, …). The default adapter writes to the log.
interface IPlatformEventPublisher {
  /// topic e.g. "management/subaccount/created"
  void publish(string topic, Json payload);
}
