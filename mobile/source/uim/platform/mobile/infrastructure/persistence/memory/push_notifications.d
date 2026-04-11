/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.push_notification;

import uim.platform.mobile.domain.entities.push_notification;
import uim.platform.mobile.domain.ports.repositories.push_notifications;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryPushNotificationRepository : PushNotificationRepository {
  private PushNotification[PushNotificationId] store;

  PushNotification findById(PushNotificationId id) {
    if (auto p = id in store)
      return *p;
    return PushNotification.init;
  }

  PushNotification[] findByApp(MobileAppId appId) {
    return store.values.filter!(n => n.appId == appId).array;
  }

  PushNotification[] findByStatus(MobileAppId appId, NotificationStatus status) {
    return store.values.filter!(n => n.appId == appId && n.status == status).array;
  }

  PushNotification[] findByTenant(TenantId tenantId) {
    return store.values.filter!(n => n.tenantId == tenantId).array;
  }

  void save(PushNotification notif) {
    store[notif.id] = notif;
  }

  void update(PushNotification notif) {
    store[notif.id] = notif;
  }

  void remove(PushNotificationId id) {
    store.remove(id);
  }

  size_t countByApp(MobileAppId appId) {
    return store.values.filter!(n => n.appId == appId).array.length;
  }

  size_t countByTenant(TenantId tenantId) {
    return store.values.filter!(n => n.tenantId == tenantId).array.length;
  }
}
