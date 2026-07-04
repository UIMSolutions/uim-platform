/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.models.task;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// Web view-model for a WZTask inbox item.
struct TaskViewModel {
    string id;
    TenantId tenantId;
    string title;
    string description;
    string assigneeName;
    string creatorName;
    string statusLabel;
    string statusCssClass;
    string priorityLabel;
    string priorityCssClass;
    string sourceApp;
    string actionUrl;
    string dueDateFormatted;
    bool isOverdue;

    static TaskViewModel from(const WZTask t) {
        import std.datetime : Clock, unixTimeToStdTime, SysTime;
        bool overdue = (t.dueDate > 0) &&
                       (t.status != TaskStatus.completed) &&
                       (t.dueDate < Clock.currTime.toUnixTime());
        return TaskViewModel(
            t.id.value, t.tenantId, t.title, t.description,
            t.assigneeName, t.creatorName,
            labelForStatus(t.status), cssForStatus(t.status),
            labelForPriority(t.priority), cssForPriority(t.priority),
            t.sourceApp, t.actionUrl,
            formatTimestamp(t.dueDate),
            overdue
        );
    }

    private static string labelForStatus(TaskStatus s) {
        final switch (s) {
            case TaskStatus.open:       return "Open";
            case TaskStatus.inProgress: return "In Progress";
            case TaskStatus.completed:  return "Completed";
            case TaskStatus.cancelled:  return "Cancelled";
            case TaskStatus.overdue:    return "Overdue";
        }
    }

    private static string cssForStatus(TaskStatus s) {
        final switch (s) {
            case TaskStatus.open:       return "badge-primary";
            case TaskStatus.inProgress: return "badge-warning";
            case TaskStatus.completed:  return "badge-success";
            case TaskStatus.cancelled:  return "badge-secondary";
            case TaskStatus.overdue:    return "badge-danger";
        }
    }

    private static string labelForPriority(TaskPriority p) {
        final switch (p) {
            case TaskPriority.low:      return "Low";
            case TaskPriority.medium:   return "Medium";
            case TaskPriority.high:     return "High";
            case TaskPriority.veryHigh: return "Very High";
        }
    }

    private static string cssForPriority(TaskPriority p) {
        final switch (p) {
            case TaskPriority.low:      return "text-muted";
            case TaskPriority.medium:   return "text-info";
            case TaskPriority.high:     return "text-warning";
            case TaskPriority.veryHigh: return "text-danger fw-bold";
        }
    }
}

/// View-model for the task inbox page.
struct TaskListViewModel {
    TenantId tenantId;
    string assigneeId;
    TaskViewModel[] items;
    size_t openCount;
    size_t overdueCount;
    string errorMessage;
    bool hasError() const { return errorMessage.length > 0; }
}


