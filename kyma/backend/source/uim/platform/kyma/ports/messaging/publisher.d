/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.messaging.publisher;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driven port: publishes domain events ("kyma.function.created", ...) to an
/// event broker (SAP Event Mesh, NATS, Kafka) or the technical log.
interface IKymaEventPublisher {
  void publish(string topic, Json payload);
}
