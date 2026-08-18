/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.ports.usecases.event_channels;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:

interface IManageEventChannelsUseCase {

    EventChannel getEventChannel(TenantId tenantId, EventChannelId id);
    EventChannel[] listEventChannels(TenantId tenantId);
    UsecaseResult createEventChannel(EventChannelDTO dto);
    UsecaseResult updateEventChannel(EventChannelDTO dto);
    UsecaseResult deleteEventChannel(TenantId tenantId, EventChannelId id);

}
