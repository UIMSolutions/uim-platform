/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port: publish an event to a topic.
module uim.platform.events.ports.messaging.publish_events;

import uim.platform.events;

mixin(ShowModule!());

@safe:

interface IPublishEvents {
  /// Route the event to all queues whose subscriptions match the topic.
  PublishResult publish(PublishEventRequest request);
}
