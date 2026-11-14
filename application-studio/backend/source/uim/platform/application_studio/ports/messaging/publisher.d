/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.ports.messaging.publisher;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Driven port: publishes domain events ("studio.dev-space.created", ...) to an
/// event broker (SAP Event Mesh, Kafka) or the technical log.
interface IStudioEventPublisher {
  void publish(string topic, Json payload);
}
