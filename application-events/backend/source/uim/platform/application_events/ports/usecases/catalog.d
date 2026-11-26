/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the event catalog and the delivery channels.
module uim.platform.application_events.ports.usecases.catalog;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

interface IManageTopics : IManageResource!(EventTopic, EventTopicId, TopicInput) {
  /// The topic of an event type, or EventTopic.init.
  EventTopic findByEventType(TenantId t, string eventType);
  EventTopic setStatus(TenantId t, EventTopicId id, TopicStatus status, UserId actor);
}

interface IManageChannels : IManageResource!(EventChannel, EventChannelId, ChannelInput) {
  EventChannel setStatus(TenantId t, EventChannelId id, ChannelStatus status, UserId actor);
}
