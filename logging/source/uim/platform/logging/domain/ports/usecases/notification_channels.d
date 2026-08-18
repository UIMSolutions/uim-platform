/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.usecases.notification_channels;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface IManageNotificationChannelsUseCase { 
  
  UsecaseResult createChannel(CreateNotificationChannelRequest req);

  UsecaseResult updateChannel(UpdateNotificationChannelRequest req);

  NotificationChannel getChannel(TenantId tenantId, NotificationChannelId id);

  NotificationChannel[] listChannels(TenantId tenantId);

  UsecaseResult deleteChannel(TenantId tenantId, NotificationChannelId id);
   
}
