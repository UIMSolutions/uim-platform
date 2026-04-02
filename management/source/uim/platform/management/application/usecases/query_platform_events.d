module uim.platform.connectivity.application.usecases.query_platform_events;

import uim.platform.connectivity.application.dto;
import uim.platform.management.domain.entities.platform_event;
import uim.platform.management.domain.ports.platform_event_repository;
import uim.platform.management.domain.types;

/// Use case: query platform events for audit and monitoring.
class QueryPlatformEventsUseCase {
    private PlatformEventRepository repo;

    this(PlatformEventRepository repo) {
        this.repo = repo;
    }

    PlatformEvent getById(PlatformEventId id) {
        return repo.findById(id);
    }

    PlatformEvent[] listByGlobalAccount(GlobalAccountId gaId) {
        return repo.findByGlobalAccount(gaId);
    }

    PlatformEvent[] listBySubaccount(SubaccountId subId) {
        return repo.findBySubaccount(subId);
    }

    PlatformEvent[] listByCategory(GlobalAccountId gaId, string category) {
        return repo.findByCategory(gaId, parseCategory(category));
    }

    PlatformEvent[] listBySeverity(GlobalAccountId gaId, string severity) {
        return repo.findBySeverity(gaId, parseSeverity(severity));
    }

    PlatformEvent[] listSince(GlobalAccountId gaId, long sinceTimestamp) {
        return repo.findSince(gaId, sinceTimestamp);
    }

    private PlatformEventCategory parseCategory(string s) {
        switch (s) {
        case "subaccountLifecycle":
            return PlatformEventCategory.subaccountLifecycle;
        case "entitlementChange":
            return PlatformEventCategory.entitlementChange;
        case "environmentLifecycle":
            return PlatformEventCategory.environmentLifecycle;
        case "subscriptionLifecycle":
            return PlatformEventCategory.subscriptionLifecycle;
        case "directoryChange":
            return PlatformEventCategory.directoryChange;
        case "globalAccountChange":
            return PlatformEventCategory.globalAccountChange;
        case "quotaChange":
            return PlatformEventCategory.quotaChange;
        case "securityEvent":
            return PlatformEventCategory.securityEvent;
        default:
            return PlatformEventCategory.subaccountLifecycle;
        }
    }

    private PlatformEventSeverity parseSeverity(string s) {
        switch (s) {
        case "info":
            return PlatformEventSeverity.info;
        case "warning":
            return PlatformEventSeverity.warning;
        case "error":
            return PlatformEventSeverity.error;
        case "critical":
            return PlatformEventSeverity.critical;
        default:
            return PlatformEventSeverity.info;
        }
    }
}
