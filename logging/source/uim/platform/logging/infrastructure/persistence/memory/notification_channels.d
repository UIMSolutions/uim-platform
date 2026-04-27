/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.notification_channels;

// import uim.platform.logging.domain.entities.notification_channel;
// import uim.platform.logging.domain.ports.repositories.notification_channels;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:

class MemoryNotificationChannelRepository : NotificationChannelRepository {

  size_t countActive(TenantId tenantId) {
    return findActive(tenantId).length;
  }

  NotificationChannel[] findActive(TenantId tenantId) {
    return findByTenant(tenantId).filter!(ch => ch.state == ChannelState.active).array;
  }

}
