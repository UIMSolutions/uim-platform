/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.ports.messaging.publisher;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Driven port: publishes domain events ("objectstore.bucket.created",
/// "objectstore.object.written", ...) to an event broker or the technical log.
interface IObjectStoreEventPublisher {
  void publish(string topic, Json payload);
}
