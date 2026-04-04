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

class ManageNotificationsUseCase
{
  private NotificationRepository repo;

  this(NotificationRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createNotification(CreateNotificationRequest req)
  {
    if (req.title.length == 0)
      return CommandResult("", "Notification title is required");

    auto n = Notification();
    n.id = randomUUID().toString();
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

  Notification* getNotification(NotificationId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  Notification[] listByRecipient(UserId recipientId, TenantId tenantId)
  {
    return repo.findByRecipient(recipientId, tenantId);
  }

  Notification[] listUnread(UserId recipientId, TenantId tenantId)
  {
    return repo.findUnread(recipientId, tenantId);
  }

  CommandResult markAsRead(NotificationId id, TenantId tenantId)
  {
    auto n = repo.findById(id, tenantId);
    if (n is null)
      return CommandResult("", "Notification not found");

    n.status = NotificationStatus.read_;
    n.readAt = Clock.currStdTime();
    repo.update(*n);
    return CommandResult(n.id, "");
  }

  CommandResult dismiss(NotificationId id, TenantId tenantId)
  {
    auto n = repo.findById(id, tenantId);
    if (n is null)
      return CommandResult("", "Notification not found");

    n.status = NotificationStatus.dismissed;
    repo.update(*n);
    return CommandResult(n.id, "");
  }

  void deleteNotification(NotificationId id, TenantId tenantId)
  {
    repo.remove(id, tenantId);
  }
}
