/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.subscriptions;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Use case: manage SaaS application subscriptions.
/// The SaaS provider is reached through the IProvisioningGateway port.
class ManageSubscriptionsUseCase : IManageSubscriptionsUseCase {
  protected ISubscriptionRepository repo;
  protected ISubaccountRepository subaccounts;
  protected IServicePlanRepository plans;
  protected IProvisioningGateway gateway;
  protected PlatformEventRecorder recorder;

  this(ISubscriptionRepository repo, ISubaccountRepository subaccounts, IServicePlanRepository plans,
      IProvisioningGateway gateway, PlatformEventRecorder recorder) {
    this.repo = repo;
    this.subaccounts = subaccounts;
    this.plans = plans;
    this.gateway = gateway;
    this.recorder = recorder;
  }

  UsecaseResult createSubscription(CreateSubscriptionRequest request) {
    if (request.subaccountId.isEmpty)
      return invalid("Subaccount ID is required");
    if (request.appName.length == 0)
      return invalid("Application name is required");

    auto subaccount = subaccounts.findById(request.tenantId, request.subaccountId);
    if (subaccount.isNull)
      return notFound("Subaccount");
    if (!subaccount.isActive)
      return violation("Subaccount '" ~ subaccount.displayName ~ "' is " ~ enumName(subaccount.status));
    if (repo.findByApp(request.tenantId, request.subaccountId, request.appName).any!(s => s.isLive))
      return conflict("Already subscribed to application '" ~ request.appName ~ "'");

    auto subscription = Subscription(request.tenantId);
    subscription.subaccountId = request.subaccountId;
    subscription.globalAccountId = subaccount.globalAccountId;
    subscription.appName = request.appName;
    subscription.planName = request.planName.length > 0 ? request.planName : "default";
    subscription.status = SubscriptionStatus.subscribing;
    subscription.subscribedAt = subscription.createdAt;
    subscription.subscribedBy = actor(request.subscribedBy);
    subscription.createdBy = subscription.subscribedBy;
    subscription.updatedBy = subscription.subscribedBy;
    subscription.parameters = request.parameters;
    subscription.labels = request.labels;

    // Enrich from the application catalog, if the app is listed there.
    foreach (plan; plans.findByService(request.tenantId, request.appName))
      if (plan.category == ServicePlanCategory.application) {
        subscription.appDisplayName = plan.serviceDisplayName;
        subscription.appDescription = plan.description;
        subscription.commercialAppName = plan.serviceName;
        break;
      }
    repo.save(subscription);

    auto outcome = gateway.subscribe(subscription, subaccount);
    if (outcome.success) {
      subscription.status = SubscriptionStatus.subscribed;
      subscription.isSubscriptionDone = true;
      subscription.appUrl = outcome.url;
    } else {
      subscription.status = SubscriptionStatus.error;
      subscription.errorDescription = outcome.message;
    }
    subscription.update();
    repo.update(subscription);

    recorder.record(request.tenantId, PlatformEventRecorder.ofSubscription(subscription),
      EnvironmentEventCategory.subscriptionLifecycle,
      outcome.success ? "subscription.created" : "subscription.failed",
      (outcome.success ? "Subscribed to " : "Subscription failed: ") ~ request.appName,
      subscription.subscribedBy, outcome.success ? EnvironmentEventSeverity.info : EnvironmentEventSeverity.error);

    if (!outcome.success)
      return UsecaseResult(false, subscription.id.value, "Subscription failed: " ~ outcome.message, ResultCode.ruleViolation);
    return created(subscription.id.value, "Subscribed to " ~ request.appName);
  }

  UsecaseResult unsubscribeSubscription(TenantId tenantId, SubscriptionId id) {
    auto subscription = repo.findById(tenantId, id);
    if (subscription.isNull)
      return notFound("Subscription");
    if (subscription.status != SubscriptionStatus.subscribed)
      return violation("Subscription must be in status 'subscribed' (is '" ~ enumName(subscription.status) ~ "')");

    auto outcome = gateway.unsubscribe(subscription);
    if (!outcome.success)
      return violation("Unsubscribe failed: " ~ outcome.message);

    return guarded(() {
      subscription.unsubscribe(UserId("system"));
      repo.update(subscription);
      recorder.record(tenantId, PlatformEventRecorder.ofSubscription(subscription),
        EnvironmentEventCategory.subscriptionLifecycle, "subscription.deleted",
        "Unsubscribed from " ~ subscription.appName, subscription.updatedBy);
      return ok(subscription.id.value, "Unsubscribed from " ~ subscription.appName);
    });
  }

  UsecaseResult updateSubscriptionPlan(UpdateSubscriptionRequest req) {
    auto subscription = repo.findById(req.tenantId, req.subscriptionId);
    if (subscription.isNull)
      return notFound("Subscription");
    if (!subscription.isLive)
      return violation("Only active subscriptions can change their plan");

    auto before = subscription.planName;
    if (req.planName.length > 0)
      subscription.planName = req.planName;
    if (req.parameters.length > 0)
      subscription.parameters = req.parameters;
    subscription.update();

    repo.update(subscription);
    recorder.record(req.tenantId, PlatformEventRecorder.ofSubscription(subscription),
      EnvironmentEventCategory.subscriptionLifecycle, "subscription.updated",
      "Subscription of " ~ subscription.appName ~ " updated", subscription.updatedBy,
      EnvironmentEventSeverity.info, ["fromPlan": before, "toPlan": subscription.planName]);
    return ok(subscription.id.value, "Subscription updated");
  }

  Subscription getSubscription(TenantId tenantId, SubscriptionId id) {
    return repo.findById(tenantId, id);
  }

  Subscription[] listSubscriptions(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Subscription[] listSubscriptions(TenantId tenantId, SubaccountId subId) {
    return repo.findBySubaccount(tenantId, subId);
  }
}
