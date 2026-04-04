/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.notification;

import uim.platform.workzone.domain.types;

/// A user notification — cross-system alerts and action items.
struct Notification {
  NotificationId id;
  TenantId tenantId;
  UserId recipientId;
  string title;
  string body_;
  string sourceApp; // originating application
  string sourceObjectType; // e.g., "task", "content", "workspace"
  string sourceObjectId;
  string actionUrl; // deep link
  NotificationPriority priority = NotificationPriority.medium;
  NotificationStatus status = NotificationStatus.unread;
  long createdAt;
  long readAt;
  long expiresAt;
}
