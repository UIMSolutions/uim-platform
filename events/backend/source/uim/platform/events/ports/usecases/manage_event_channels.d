/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.ports.usecases.manage_event_channels;

import uim.platform.events;

mixin(ShowModule!());

@safe:

interface IManageEventChannels {
  EventChannel[] listEventChannels(TenantId tenantId);
  EventChannel getEventChannel(TenantId tenantId, EventChannelId id);
  EventChannel createEventChannel(CreateEventChannelRequest request);
  EventChannel updateEventChannel(UpdateEventChannelRequest request);
  /// Also removes the bindings of the channel.
  void deleteEventChannel(TenantId tenantId, EventChannelId id);
}
