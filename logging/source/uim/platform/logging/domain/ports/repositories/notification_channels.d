/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.repositories.notification_channels;

// import uim.platform.logging.domain.entities.notification_channel;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface NotificationChannelRepository {
  bool existsById(NotificationChannelId id);
  NotificationChannel findById(NotificationChannelId id);

  size_t countByTenant(TenantId tenantId);
  NotificationChannel[] findByTenant(TenantId tenantId);

  NotificationChannel[] findActive(TenantId tenantId);

  void save(NotificationChannel ch);
  void update(NotificationChannel ch);
  void remove(NotificationChannelId id);
}
