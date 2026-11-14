/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.ports.usecases.channels;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Maintain service channels of a Cloud Connector and open / close them.
interface IManageChannelsUseCase : IManageResource!(ServiceChannel, ChannelId,
    CreateChannelRequest, UpdateChannelRequest) {
  UsecaseResult open(TenantId tenantId, ChannelId id, UserId actor);
  UsecaseResult close(TenantId tenantId, ChannelId id, UserId actor);
}
