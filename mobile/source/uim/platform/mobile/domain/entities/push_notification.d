/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.push_notification;

import uim.platform.mobile.domain.types;

struct PushNotification {
  mixin TenantEntity!(PushNotificationId);

  MobileAppId appId;
  string title;
  string body_;
  string payload;          // JSON custom data
  PushProvider provider;
  NotificationStatus status;
  NotificationPriority priority;
  string[] targetDevices;  // device registration IDs
  string[] targetTopics;   // topic-based targeting
  long scheduledAt;
  long sentAt;
  long expiresAt;
  int deliveredCount;
  int failedCount;

  Json toJson() const {
      return entityToJson
          .set("appId", appId.value)
          .set("title", title)
          .set("body", body_)
          .set("payload", payload)
          .set("provider", provider.to!string)
          .set("status", status.to!string)
          .set("priority", priority.to!string)
          .set("targetDevices", targetDevices.array)
          .set("targetTopics", targetTopics.array)
          .set("scheduledAt", scheduledAt)
          .set("sentAt", sentAt)
          .set("expiresAt", expiresAt)
          .set("deliveredCount", deliveredCount)
          .set("failedCount", failedCount);
  }
}
