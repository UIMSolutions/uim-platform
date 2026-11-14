/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.messaging.publisher;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Driven port: publishes domain events ("portal.site.published", ...) to an
/// event broker (SAP Event Mesh, NATS, Kafka) or the technical log.
interface IPortalEventPublisher {
  void publish(string topic, Json payload);
}
