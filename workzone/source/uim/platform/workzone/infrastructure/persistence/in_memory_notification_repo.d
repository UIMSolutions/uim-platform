module uim.platform.xyz.infrastructure.persistence.memory.notification_repo;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.notification;
import uim.platform.xyz.domain.ports.notification_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryNotificationRepository : NotificationRepository
{
    private Notification[NotificationId] store;

    Notification[] findByRecipient(UserId recipientId, TenantId tenantId)
    {
        return store.byValue().filter!(n => n.tenantId == tenantId && n.recipientId == recipientId).array;
    }

    Notification* findById(NotificationId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    Notification[] findUnread(UserId recipientId, TenantId tenantId)
    {
        return store.byValue().filter!(n =>
            n.tenantId == tenantId && n.recipientId == recipientId && n.status == NotificationStatus.unread
        ).array;
    }

    void save(Notification notification) { store[notification.id] = notification; }
    void update(Notification notification) { store[notification.id] = notification; }
    void remove(NotificationId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}
