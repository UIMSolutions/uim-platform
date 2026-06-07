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

import uim.platform.management;

// mixin(ShowModule!());

@safe:
/// Use case: manage SaaS application subscriptions.
class ManageSubscriptionsUseCase { // TODO: UIMUseCase {
  private SubscriptionRepository repo;
  private EnvironmentEventRepository eventRepo;

  this(SubscriptionRepository repo, EnvironmentEventRepository eventRepo) {
    this.repo = repo;
    this.eventRepo = eventRepo;
  }

  CommandResult createSubscription(CreateSubscriptionRequest request) {
    if (request.subaccountId.isEmpty)
      return CommandResult(false, "", "Subaccount ID is required");
    if (request.appName.length == 0)
      return CommandResult(false, "", "Application name is required");

    // Check for existing subscription to same app
    auto existing = repo.findByApp(request.tenantId, request.subaccountId, request.appName);
    foreach (e; existing) {
      if (e.status == SubscriptionStatus.subscribed || e.status == SubscriptionStatus.subscribing)
        return CommandResult(false, "", "Already subscribed to application '" ~ request.appName ~ "'");
    }

    auto subscription = Subscription(request.tenantId);
    subscription.tenantId = request.tenantId;
    subscription.subaccountId = request.subaccountId;
    subscription.globalAccountId = request.globalAccountId;
    subscription.appName = request.appName;
    subscription.planName = request.planName;
    subscription.status = SubscriptionStatus.subscribing;
    subscription.subscribedAt = clockSeconds();
    subscription.updatedAt = subscription.subscribedAt;
    subscription.subscribedBy = request.subscribedBy;
    subscription.parameters = request.parameters;
    subscription.labels = request.labels;

    repo.save(subscription);

    // Complete subscription (simulated)
    subscription.status = SubscriptionStatus.subscribed;
    subscription.isSubscriptionDone = true;
    subscription.appUrl = "/apps/" ~ request.appName ~ "/" ~ subscription.id.value;
    repo.update(subscription);

    emitEvent(eventRepo, request.globalAccountId.value, request.subaccountId.value, EnvironmentEventCategory.subscriptionLifecycle,
      "subscription.created", "Subscribed to " ~ request.appName, request.subscribedBy);

    return CommandResult(true, subscription.id.value, "");
  }

  CommandResult unsubscribeSubscription(TenantId tenantId, SubscriptionId id) {
    auto subscription = repo.findById(tenantId, id);
    if (subscription.isNull)
      return CommandResult(false, "", "Subscription not found");
    if (subscription.status != SubscriptionStatus.subscribed)
      return CommandResult(false, "", "Subscription must be in subscribed status");

    subscription.status = SubscriptionStatus.unsubscribing;
    subscription.updatedAt = clockSeconds();
    repo.update(subscription);

    // Complete unsubscription
    subscription.status = SubscriptionStatus.unsubscribed;
    repo.update(subscription);

    emitEvent(eventRepo, subscription.globalAccountId.value, subscription.subaccountId.value, EnvironmentEventCategory.subscriptionLifecycle,
      "subscription.deleted", "Unsubscribed from " ~ subscription.appName, UserId("system"));

    return CommandResult(true, subscription.id.value, "");
  }

  CommandResult updateSubscriptionPlan(UpdateSubscriptionRequest req) {
    auto subscription = repo.findById(req.tenantId, req.subscriptionId);
    if (subscription.isNull)
      return CommandResult(false, "", "Subscription not found");

    if (req.planName.length > 0)
      subscription.planName = req.planName;
    if (req.parameters.length > 0)
      subscription.parameters = req.parameters;
    subscription.updatedAt = clockSeconds();

    repo.update(subscription);
    return CommandResult(true, subscription.id.value, "");
  }

  Subscription getSubscription(TenantId tenantId, SubscriptionId id) {
    return repo.findById(tenantId, id);
  }

  Subscription[] listSubscriptions(TenantId tenantId, SubaccountId subId) {
    return repo.findBySubaccount(tenantId, subId);
  }
}
