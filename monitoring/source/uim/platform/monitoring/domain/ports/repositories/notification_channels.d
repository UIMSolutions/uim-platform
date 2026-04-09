/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.ports.repositories.notification_channels;

// import uim.platform.monitoring.domain.entities.notification_channel;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Port: outgoing - notification channel persistence.
interface NotificationChannelRepository {
  NotificationChannel findById(NotificationChannelId id);
  NotificationChannel[] findByTenant(TenantId tenantId);
  NotificationChannel[] findByType(TenantId tenantId, ChannelType channelType);
  NotificationChannel[] findActive(TenantId tenantId);
  void save(NotificationChannel channel);
  void update(NotificationChannel channel);
  void remove(NotificationChannelId id);
}
