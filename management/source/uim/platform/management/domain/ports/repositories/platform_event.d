module uim.platform.management.domain.ports.repositories.platform_event;

import uim.platform.management.domain.entities.platform_event;
import uim.platform.management.domain.types;

/// Port: outgoing — platform event persistence.
interface PlatformEventRepository {
    PlatformEvent findById(PlatformEventId id);
    PlatformEvent[] findByGlobalAccount(GlobalAccountId globalAccountId);
    PlatformEvent[] findBySubaccount(SubaccountId subaccountId);
    PlatformEvent[] findByCategory(GlobalAccountId globalAccountId, PlatformEventCategory category);
    PlatformEvent[] findBySeverity(GlobalAccountId globalAccountId, PlatformEventSeverity severity);
    PlatformEvent[] findSince(GlobalAccountId globalAccountId, long sinceTimestamp);
    void save(PlatformEvent event);
    void remove(PlatformEventId id);
}
