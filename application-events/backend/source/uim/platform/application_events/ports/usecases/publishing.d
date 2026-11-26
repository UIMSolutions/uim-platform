/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the producers: publish CloudEvents.
module uim.platform.application_events.ports.usecases.publishing;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

interface IPublishEvents {
  /// Validate, route and (deliverOnPublish) deliver an event. Publishing
  /// the same event id of the same source again returns the first result
  /// (duplicate = true) and routes nothing.
  PublishResult publish(PublishRequest r);
  /// Which subscriptions would receive the event, without creating messages.
  PublishResult preview(PublishRequest r);
}
