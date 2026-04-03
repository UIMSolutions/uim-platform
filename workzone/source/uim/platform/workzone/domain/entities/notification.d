module uim.platform.xyz.domain.entities.notification;

import domain.types;

/// A user notification — cross-system alerts and action items.
struct Notification
{
    NotificationId id;
    TenantId tenantId;
    UserId recipientId;
    string title;
    string body_;
    string sourceApp;        // originating application
    string sourceObjectType; // e.g., "task", "content", "workspace"
    string sourceObjectId;
    string actionUrl;        // deep link
    NotificationPriority priority = NotificationPriority.medium;
    NotificationStatus status = NotificationStatus.unread;
    long createdAt;
    long readAt;
    long expiresAt;
}
