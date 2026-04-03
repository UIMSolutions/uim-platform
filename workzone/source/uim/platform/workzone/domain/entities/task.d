module uim.platform.workzone.domain.entities.task;

import uim.platform.workzone.domain.types;

/// A unified task — aggregated from multiple backend systems into a single inbox.
struct Task
{
    TaskId id;
    TenantId tenantId;
    UserId assigneeId;
    string assigneeName;
    UserId creatorId;
    string creatorName;
    string title;
    string description;
    TaskStatus status = TaskStatus.open;
    TaskPriority priority = TaskPriority.medium;
    string sourceApp;        // originating system
    string sourceTaskId;     // original task ID in source
    string actionUrl;        // deep link to source
    string category;
    string[] tags;
    long dueDate;
    long completedAt;
    long createdAt;
    long updatedAt;
}
