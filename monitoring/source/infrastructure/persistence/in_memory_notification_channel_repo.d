module infrastructure.persistence.in_memory_notification_channel_repo;

import domain.types;
import domain.entities.notification_channel;
import domain.ports.notification_channel_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryNotificationChannelRepository : NotificationChannelRepository
{
    private NotificationChannel[NotificationChannelId] store;

    NotificationChannel findById(NotificationChannelId id)
    {
        if (auto p = id in store)
            return *p;
        return NotificationChannel.init;
    }

    NotificationChannel[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    NotificationChannel[] findByType(TenantId tenantId, ChannelType channelType)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.channelType == channelType)
            .array;
    }

    NotificationChannel[] findActive(TenantId tenantId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.state == ChannelState.active)
            .array;
    }

    void save(NotificationChannel channel) { store[channel.id] = channel; }
    void update(NotificationChannel channel) { store[channel.id] = channel; }
    void remove(NotificationChannelId id) { store.remove(id); }
}
