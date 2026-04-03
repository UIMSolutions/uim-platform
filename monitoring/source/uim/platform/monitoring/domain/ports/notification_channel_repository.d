module uim.platform.monitoring.domain.ports.notification_channel_repository;

import uim.platform.monitoring.domain.entities.notification_channel;
import uim.platform.monitoring.domain.types;

/// Port: outgoing - notification channel persistence.
interface NotificationChannelRepository
{
    NotificationChannel findById(NotificationChannelId id);
    NotificationChannel[] findByTenant(TenantId tenantId);
    NotificationChannel[] findByType(TenantId tenantId, ChannelType channelType);
    NotificationChannel[] findActive(TenantId tenantId);
    void save(NotificationChannel channel);
    void update(NotificationChannel channel);
    void remove(NotificationChannelId id);
}
