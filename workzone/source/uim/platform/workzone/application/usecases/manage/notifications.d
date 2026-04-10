/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.notifications;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.notification;
import uim.platform.workzone.domain.ports.repositories.notifications;
import uim.platform.workzone.application.dto;

class ManageNotificationsUseCase : UIMUseCase {
  private NotificationRepository repo;

  this(NotificationRepository repo) {
    this.repo = repo;
  }

  CommandResult createNotification(CreateNotificationRequest req) {
    if (req.title.length == 0)
      return CommandResult(false, "", "Notification title is required");

    auto n = Notification();
    n.id = randomUUID();
    n.tenantId = req.tenantId;
    n.recipientId = req.recipientId;
    n.title = req.title;
    n.body_ = req.body_;
    n.sourceApp = req.sourceApp;
    n.sourceObjectType = req.sourceObjectType;
    n.sourceObjectId = req.sourceObjectId;
    n.actionUrl = req.actionUrl;
    n.priority = req.priority;
    n.status = NotificationStatus.unread;
    n.createdAt = Clock.currStdTime();
    n.expiresAt = req.expiresAt;

    repo.save(n);
    return CommandResult(n.id, "");
  }

  Notification* getNotification(NotificationId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Notification[] listByRecipient(UserId recipienttenantId, id tenantId) {
    return repo.findByRecipient(recipienttenantId, id);
  }

  Notification[] listUnread(UserId recipienttenantId, id tenantId) {
    return repo.findUnread(recipienttenantId, id);
  }

  CommandResult markAsRead(NotificationId tenantId, id tenantId) {
    auto n = repo.findById(tenantId, id);
    if (n is null)
      return CommandResult(false, "", "Notification not found");

    n.status = NotificationStatus.read_;
    n.readAt = Clock.currStdTime();
    repo.update(*n);
    return CommandResult(n.id, "");
  }

  CommandResult dismiss(NotificationId tenantId, id tenantId) {
    auto n = repo.findById(tenantId, id);
    if (n is null)
      return CommandResult(false, "", "Notification not found");

    n.status = NotificationStatus.dismissed;
    repo.update(*n);
    return CommandResult(n.id, "");
  }

  void deleteNotification(NotificationId tenantId, id tenantId) {
    repo.remove(tenantId, id);
  }
}
