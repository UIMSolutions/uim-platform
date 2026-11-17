/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.inbox;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: tasks. open → inProgress → completed / cancelled; overdue is
/// set by housekeeping; completed or cancelled tasks can be reopened.
class ManageTasksUseCase
  : ResourceUseCase!(WorkTask, TaskId, CreateTaskRequest, UpdateTaskRequest),
  IManageTasksUseCase {

  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.tasks, publisher, "Task", "workzone.task");
  }

  override protected WorkTask build(CreateTaskRequest r) {
    auto t = WorkTask(r.tenantId);
    assignMatching(t, r.spec);
    if (t.assigneeId.isEmpty)
      t.assigneeId = r.actor;
    check(t);
    return t;
  }

  override protected void apply(ref WorkTask t, TaskSpec spec) {
    ensureState(t.status.isPending, "Task '" ~ t.title ~ "' is " ~ enumText(t.status) ~ " — reopen it first");
    assignMatching(t, spec);
    check(t);
    if (t.status == TaskStatus.overdue && (t.dueAt == 0 || t.dueAt > nowStdTime()))
      t.status = TaskStatus.open; // due date moved into the future
  }

  protected static void check(ref WorkTask t) {
    t.title = t.title.strip;
    validateDisplayName("Task title", t.title, 200);
    validate(!t.assigneeId.isEmpty, "assigneeId is required");
    if (t.assigneeName.strip.length == 0)
      t.assigneeName = t.assigneeId.value;
    validate(t.actionUrl.length == 0 || isLaunchTarget(t.actionUrl), "Action URL '" ~ t.actionUrl ~ "' is invalid");
    t.tags = normalizedNames(t.tags);
  }

  UsecaseResult start(TenantId tenantId, TaskId id, UserId actor) {
    return transition(tenantId, id, actor, "started", (ref WorkTask t) {
      ensureState(t.status == TaskStatus.open || t.status == TaskStatus.overdue, "Task '" ~ t.title ~ "' is "
          ~ enumText(t.status));
      if (t.status == TaskStatus.open)
        t.status = TaskStatus.inProgress;
    });
  }

  UsecaseResult complete(TenantId tenantId, TaskId id, UserId actor) {
    return transition(tenantId, id, actor, "completed", (ref WorkTask t) {
      ensureState(t.status.isPending, "Task '" ~ t.title ~ "' is already " ~ enumText(t.status));
      t.status = TaskStatus.completed;
      t.completedAt = nowStdTime();
    });
  }

  UsecaseResult cancel(TenantId tenantId, TaskId id, UserId actor) {
    return transition(tenantId, id, actor, "cancelled", (ref WorkTask t) {
      ensureState(t.status.isPending, "Task '" ~ t.title ~ "' is already " ~ enumText(t.status));
      t.status = TaskStatus.cancelled;
    });
  }

  UsecaseResult reopen(TenantId tenantId, TaskId id, UserId actor) {
    return transition(tenantId, id, actor, "reopened", (ref WorkTask t) {
      ensureState(!t.status.isPending, "Task '" ~ t.title ~ "' is still " ~ enumText(t.status));
      t.status = t.dueAt > 0 && nowStdTime() > t.dueAt ? TaskStatus.overdue : TaskStatus.open;
      t.completedAt = 0;
    });
  }
}

/// Interactor: notifications. The recipient must exist when user profiles are maintained.
class ManageNotificationsUseCase
  : ResourceUseCase!(Notification, NotificationId, CreateNotificationRequest, UpdateNotificationRequest),
  IManageNotificationsUseCase {

  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.notifications, publisher, "Notification", "workzone.notification");
  }

  override protected Notification build(CreateNotificationRequest r) {
    auto n = Notification(r.tenantId);
    assignMatching(n, r.spec);
    if (n.priority == NotificationPriority.critical)
      n.status = NotificationStatus.actionRequired;
    check(n);
    validate(n.expiresAt == 0 || n.expiresAt > n.createdAt, "A notification cannot expire in the past");
    return n;
  }

  override protected void apply(ref Notification n, NotificationSpec spec) {
    auto recipient = n.recipientId;
    assignMatching(n, spec, ["recipientId"]);
    n.recipientId = recipient; // delivered notifications keep their recipient
    check(n);
  }

  protected void check(ref Notification n) {
    n.title = n.title.strip;
    validateDisplayName("Notification title", n.title, 200);
    validate(!n.recipientId.isEmpty, "recipientId is required");
    auto recipient = n.recipientId;
    if (repos.userProfiles.findByTenant(n.tenantId).length > 0)
      ensureFound(repos.userProfiles.findMatching(n.tenantId, (const UserProfile p) => p.userId == recipient).length > 0,
        "User '" ~ recipient.value ~ "' has no profile");
    validate(n.actionUrl.length == 0 || isLaunchTarget(n.actionUrl), "Action URL '" ~ n.actionUrl ~ "' is invalid");
  }

  UsecaseResult markRead(TenantId tenantId, NotificationId id, UserId actor) {
    return transition(tenantId, id, actor, "read", (ref Notification n) {
      ensureState(n.status != NotificationStatus.dismissed, "Notification '" ~ n.title ~ "' is dismissed");
      n.status = NotificationStatus.read_;
      n.readAt = nowStdTime();
    });
  }

  UsecaseResult markUnread(TenantId tenantId, NotificationId id, UserId actor) {
    return transition(tenantId, id, actor, "unread", (ref Notification n) {
      ensureState(n.status == NotificationStatus.read_, "Only read notifications can be marked unread");
      n.status = NotificationStatus.unread;
      n.readAt = 0;
    });
  }

  UsecaseResult dismiss(TenantId tenantId, NotificationId id, UserId actor) {
    return transition(tenantId, id, actor, "dismissed", (ref Notification n) {
      ensureState(n.status != NotificationStatus.dismissed, "Notification '" ~ n.title ~ "' is already dismissed");
      n.status = NotificationStatus.dismissed;
    });
  }
}
