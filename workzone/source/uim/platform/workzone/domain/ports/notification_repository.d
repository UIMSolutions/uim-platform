module uim.platform.xyz.domain.ports.notification_repository;

import domain.types;
import domain.entities.notification;

interface NotificationRepository
{
    Notification[] findByRecipient(UserId recipientId, TenantId tenantId);
    Notification* findById(NotificationId id, TenantId tenantId);
    Notification[] findUnread(UserId recipientId, TenantId tenantId);
    void save(Notification notification);
    void update(Notification notification);
    void remove(NotificationId id, TenantId tenantId);
}
