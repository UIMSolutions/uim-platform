/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.notification;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A notification in the inbox of a user.
struct Notification {
  mixin TenantEntity!NotificationId;

  UserId recipientId;
  string title;
  string body_;
  string sourceApp;
  string sourceObjectType;
  string sourceObjectId;
  string actionUrl;
  NotificationPriority priority = NotificationPriority.medium;
  NotificationStatus status = NotificationStatus.unread;
  long readAt;
  long expiresAt; /// 0 = never; expired notifications are dismissed by housekeeping
}
