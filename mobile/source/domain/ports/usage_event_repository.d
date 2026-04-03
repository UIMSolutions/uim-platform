module uim.platform.mobile.domain.ports.usage_event_repository;

import uim.platform.mobile.domain.entities.usage_event;
import uim.platform.mobile.domain.types;

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
