module domain.ports.usage_event_repository;

import domain.entities.usage_event;
import domain.types;

/// Port: outgoing — usage event persistence.
interface UsageEventRepository
{
    UsageEvent findById(UsageEventId id);
    UsageEvent[] findByApp(MobileAppId appId);
    UsageEvent[] findByUser(MobileAppId appId, string userId);
    UsageEvent[] findByType(MobileAppId appId, UsageEventType eventType);
    UsageEvent[] findByDevice(MobileAppId appId, string deviceId);
    void save(UsageEvent event);
    void remove(UsageEventId id);
}
