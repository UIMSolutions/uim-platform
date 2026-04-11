/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.subscriptions;

// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.subscription;
// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.ports.repositories.subscriptions;
// import uim.platform.management.domain.ports.repositories.platform_events;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage SaaS application subscriptions.
class ManageSubscriptionsUseCase : UIMUseCase {
  private SubscriptionRepository repo;
  private PlatformEventRepository eventRepo;

  this(SubscriptionRepository repo, PlatformEventRepository eventRepo) {
    this.repo = repo;
    this.eventRepo = eventRepo;
  }

  CommandResult subscribe(CreateSubscriptionRequest request) {
    if (request.subaccountId.isEmpty)
      return CommandResult(false, "", "Subaccount ID is required");
    if (request.appName.length == 0)
      return CommandResult(false, "", "Application name is required");

    // Check for existing subscription to same app
    auto existing = repo.findByApp(request.subaccountId, request.appName);
    foreach (e; existing) {
      if (e.status == SubscriptionStatus.subscribed || e.status == SubscriptionStatus.subscribing)
        return CommandResult(false, "", "Already subscribed to application '" ~ request.appName ~ "'");
    }

    Subscription subscription;
    subscription.id = randomUUID();
    subscription.subaccountId = request.subaccountId;
    subscription.globalAccountId = request.globalAccountId;
    subscription.appName = request.appName;
    subscription.planName = request.planName;
    subscription.status = SubscriptionStatus.subscribing;
    subscription.subscribedAt = clockSeconds();
    subscription.modifiedAt = subscription.subscribedAt;
    subscription.subscribedBy = request.subscribedBy;
    subscription.parameters = request.parameters;
    subscription.labels = request.labels;

    repo.save(subscription);

    // Complete subscription (simulated)
    subscription.status = SubscriptionStatus.subscribed;
    subscription.isSubscriptionDone = true;
    subscription.appUrl = "/apps/" ~ request.appName ~ "/" ~ subscription.id.toString;
    subscription.tenantId = "tenant-" ~ subscription.id.toString[0 .. 8];
    repo.update(subscription);

    emitEvent(request.globalAccountId.toString, request.subaccountId.toString, PlatformEventCategory.subscriptionLifecycle,
      "subscription.created", "Subscribed to " ~ request.appName, request.subscribedBy);

    return CommandResult(true, subscription.id.toString, "");
  }

  CommandResult unsubscribe(string id) {
    return unsubscribe(SubscriptionId(id));
  }

  CommandResult unsubscribe(SubscriptionId id) {
    auto subscription = repo.findById(id);
    if (subscription.id.isEmpty)
      return CommandResult(false, "", "Subscription not found");
    if (subscription.status != SubscriptionStatus.subscribed)
      return CommandResult(false, "", "Subscription must be in subscribed status");

    subscription.status = SubscriptionStatus.unsubscribing;
    subscription.modifiedAt = clockSeconds();
    repo.update(subscription);

    // Complete unsubscription
    subscription.status = SubscriptionStatus.unsubscribed;
    repo.update(subscription);

    emitEvent(subscription.globalAccountId.toString, subscription.subaccountId.toString, PlatformEventCategory.subscriptionLifecycle,
      "subscription.deleted", "Unsubscribed from " ~ subscription.appName, "system");

    return CommandResult(true, subscription.id.toString, "");
  }

  CommandResult updatePlan(string id, UpdateSubscriptionRequest req) {
    return updatePlan(SubscriptionId(id), req);
  }

  CommandResult updatePlan(SubscriptionId id, UpdateSubscriptionRequest req) {
    auto subscription = repo.findById(id);
    if (subscription.id.isEmpty)
      return CommandResult(false, "", "Subscription not found");

    if (req.planName.length > 0)
      subscription.planName = req.planName;
    if (req.parameters.length > 0)
      subscription.parameters = req.parameters;
    subscription.modifiedAt = clockSeconds();

    repo.update(subscription);
    return CommandResult(true, subscription.id.toString, "");
  }

  Subscription getById(string id) {
    return getById(SubscriptionId(id));
  }

  Subscription getById(SubscriptionId id) {
    return repo.findById(id);
  }

  Subscription[] listBySubaccount(string subId) {
    return listBySubaccount(SubaccountId(subId));
  }

  Subscription[] listBySubaccount(SubaccountId subId) {
    return repo.findBySubaccount(subId);
  }
}
