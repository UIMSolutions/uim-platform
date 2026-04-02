module uim.platform.connectivity.application.usecases.manage_subscriptions;

import uim.platform.connectivity.application.dto;
import uim.platform.management.domain.entities.subscription;
import uim.platform.management.domain.entities.platform_event;
import uim.platform.management.domain.ports.subscription_repository;
import uim.platform.management.domain.ports.platform_event_repository;
import uim.platform.management.domain.types;

/// Use case: manage SaaS application subscriptions.
class ManageSubscriptionsUseCase {
    private SubscriptionRepository repo;
    private PlatformEventRepository eventRepo;

    this(SubscriptionRepository repo, PlatformEventRepository eventRepo) {
        this.repo = repo;
        this.eventRepo = eventRepo;
    }

    CommandResult subscribe(CreateSubscriptionRequest req) {
        if (req.subaccountId.length == 0)
            return CommandResult(false, "", "Subaccount ID is required");
        if (req.appName.length == 0)
            return CommandResult(false, "", "Application name is required");

        // Check for existing subscription to same app
        auto existing = repo.findByApp(req.subaccountId, req.appName);
        foreach (ref e; existing) {
            if (e.status == SubscriptionStatus.subscribed || e.status == SubscriptionStatus
                .subscribing)
                return CommandResult(false, "", "Already subscribed to application '" ~ req.appName ~ "'");
        }

        import std.uuid : randomUUID;

        auto id = randomUUID().toString();

        Subscription sub;
        sub.id = id;
        sub.subaccountId = req.subaccountId;
        sub.globalAccountId = req.globalAccountId;
        sub.appName = req.appName;
        sub.planName = req.planName;
        sub.status = SubscriptionStatus.subscribing;
        sub.subscribedAt = clockSeconds();
        sub.modifiedAt = sub.subscribedAt;
        sub.subscribedBy = req.subscribedBy;
        sub.parameters = req.parameters;
        sub.labels = req.labels;

        repo.save(sub);

        // Complete subscription (simulated)
        sub.status = SubscriptionStatus.subscribed;
        sub.isSubscriptionDone = true;
        sub.appUrl = "/apps/" ~ req.appName ~ "/" ~ id;
        sub.tenantId = "tenant-" ~ id[0 .. 8];
        repo.update(sub);

        emitEvent(req.globalAccountId, req.subaccountId,
            PlatformEventCategory.subscriptionLifecycle,
            "subscription.created", "Subscribed to " ~ req.appName, req.subscribedBy);

        return CommandResult(true, id, "");
    }

    CommandResult unsubscribe(SubscriptionId id) {
        auto sub = repo.findById(id);
        if (sub.id.length == 0)
            return CommandResult(false, "", "Subscription not found");
        if (sub.status != SubscriptionStatus.subscribed)
            return CommandResult(false, "", "Subscription must be in subscribed status");

        sub.status = SubscriptionStatus.unsubscribing;
        sub.modifiedAt = clockSeconds();
        repo.update(sub);

        // Complete unsubscription
        sub.status = SubscriptionStatus.unsubscribed;
        repo.update(sub);

        emitEvent(sub.globalAccountId, sub.subaccountId,
            PlatformEventCategory.subscriptionLifecycle,
            "subscription.deleted", "Unsubscribed from " ~ sub.appName, "system");

        return CommandResult(true, id, "");
    }

    CommandResult updatePlan(SubscriptionId id, UpdateSubscriptionRequest req) {
        auto sub = repo.findById(id);
        if (sub.id.length == 0)
            return CommandResult(false, "", "Subscription not found");

        if (req.planName.length > 0)
            sub.planName = req.planName;
        if (req.parameters.length > 0)
            sub.parameters = req.parameters;
        sub.modifiedAt = clockSeconds();

        repo.update(sub);
        return CommandResult(true, id, "");
    }

    Subscription getById(SubscriptionId id) {
        return repo.findById(id);
    }

    Subscription[] listBySubaccount(SubaccountId subId) {
        return repo.findBySubaccount(subId);
    }

    private void emitEvent(string gaId, string subId, PlatformEventCategory cat,
        string eventType, string desc, string initiatedBy) {
        import std.uuid : randomUUID;

        PlatformEvent ev;
        ev.id = randomUUID().toString();
        ev.globalAccountId = gaId;
        ev.subaccountId = subId;
        ev.category = cat;
        ev.severity = PlatformEventSeverity.info;
        ev.eventType = eventType;
        ev.description = desc;
        ev.initiatedBy = initiatedBy;
        ev.sourceService = "cloud-management";
        ev.timestamp = clockSeconds();
        eventRepo.save(ev);
    }

    private long clockSeconds() {
        import core.time : MonoTime;

        return MonoTime.currTime.ticks / 10_000_000;
    }
}
