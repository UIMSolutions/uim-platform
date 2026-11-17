/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.ports.usecases.inbox;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Tasks of "My Inbox".
interface IManageTasksUseCase : IManageResource!(WorkTask, TaskId, CreateTaskRequest, UpdateTaskRequest) {
  UsecaseResult start(TenantId tenantId, TaskId id, UserId actor);
  UsecaseResult complete(TenantId tenantId, TaskId id, UserId actor);
  UsecaseResult cancel(TenantId tenantId, TaskId id, UserId actor);
  UsecaseResult reopen(TenantId tenantId, TaskId id, UserId actor);
}

/// Notifications of users.
interface IManageNotificationsUseCase : IManageResource!(Notification, NotificationId, CreateNotificationRequest, UpdateNotificationRequest) {
  UsecaseResult markRead(TenantId tenantId, NotificationId id, UserId actor);
  UsecaseResult markUnread(TenantId tenantId, NotificationId id, UserId actor);
  UsecaseResult dismiss(TenantId tenantId, NotificationId id, UserId actor);
}
