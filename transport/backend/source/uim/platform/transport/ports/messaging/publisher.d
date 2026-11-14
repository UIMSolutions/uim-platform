/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.ports.messaging.publisher;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Driven port: publish transport domain events (Event Mesh, Kafka, log, ...).
interface ITransportEventPublisher {
  void publish(string topic, Json payload);
}

/// Topics published by the transport service.
enum TransportTopics : string {
  requestCreated = "transport/request/created",
  requestExported = "transport/request/exported",
  requestForwarded = "transport/request/forwarded",
  importFinished = "transport/import/finished",
  queueEntryReset = "transport/queue/reset",
}
