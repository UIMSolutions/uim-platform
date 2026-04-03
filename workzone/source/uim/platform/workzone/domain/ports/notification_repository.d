module uim.platform.xyz.domain.ports.notification_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.notification;

interface NotificationRepository
{
    Notification[] findByRecipient(UserId recipientId, TenantId tenantId);
    Notification* findById(NotificationId id, TenantId tenantId);
    Notification[] findUnread(UserId recipientId, TenantId tenantId);
    void save(Notification notification);
    void update(Notification notification);
    void remove(NotificationId id, TenantId tenantId);
}
