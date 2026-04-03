module uim.platform.workzone.domain.ports.notification_repository;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.notification;

interface NotificationRepository
{
    Notification[] findByRecipient(UserId recipientId, TenantId tenantId);
    Notification* findById(NotificationId id, TenantId tenantId);
    Notification[] findUnread(UserId recipientId, TenantId tenantId);
    void save(Notification notification);
    void update(Notification notification);
    void remove(NotificationId id, TenantId tenantId);
}
