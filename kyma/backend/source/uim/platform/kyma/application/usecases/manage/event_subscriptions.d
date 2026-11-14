/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.event_subscriptions;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Interactor: eventing subscriptions with pause / resume.
class ManageEventSubscriptionsUseCase
  : ResourceUseCase!(EventSubscription, EventSubscriptionId, CreateEventSubscriptionRequest, UpdateEventSubscriptionRequest),
  IManageEventSubscriptionsUseCase {
  protected SubscriptionPolicy policy;

  this(KymaRepositories repos, IKymaEventPublisher publisher, IClusterGateway cluster, SubscriptionPolicy policy) {
    super(repos, repos.subscriptions, publisher, cluster, "Subscription", "kyma.subscription");
    this.policy = policy;
  }

  override protected EventSubscription build(CreateEventSubscriptionRequest r) {
    auto ns = requireNamespace(r.tenantId, r.parentId);
    requireModule(r.tenantId, ns.environmentId, WorkloadKind.subscription);
    auto sub = EventSubscription(r.tenantId);
    sub.environmentId = ns.environmentId;
    sub.namespaceId = ns.id;
    sub.namespaceName = ns.name;
    assignMatching(sub, r.spec);
    sub.sinkUrl = SubscriptionPolicy.resolveSink(sub.sinkUrl, sub.sinkServiceName, sub.sinkServicePort, ns.name);
    policy.validate(sub);
    ensureState(repos.subscriptions.findByName(r.tenantId, ns.id, sub.name).isNull,
      "Subscription '" ~ sub.name ~ "' already exists in namespace '" ~ ns.name ~ "'");
    sub.status = SubscriptionStatus.pending;
    return sub;
  }

  override protected void apply(ref EventSubscription sub, EventSubscriptionSpec spec) {
    assignMatching(sub, spec, ["name"]);
    if (spec.sinkUrl.length == 0)
      sub.sinkUrl = SubscriptionPolicy.resolveSink("", sub.sinkServiceName, sub.sinkServicePort, sub.namespaceName);
    policy.validate(sub);
    if (sub.status != SubscriptionStatus.paused)
      sub.status = SubscriptionStatus.pending;
  }

  override protected Json render(EventSubscription sub) {
    return toManifest(sub);
  }

  UsecaseResult pause(TenantId tenantId, EventSubscriptionId id, UserId actor) {
    return transition(tenantId, id, actor, "paused", (ref EventSubscription sub) {
      ensureState(sub.status != SubscriptionStatus.paused, "Subscription is already paused");
      sub.status = SubscriptionStatus.paused;
    });
  }

  UsecaseResult resume(TenantId tenantId, EventSubscriptionId id, UserId actor) {
    return transition(tenantId, id, actor, "resumed", (ref EventSubscription sub) {
      ensureState(sub.status == SubscriptionStatus.paused, "Only a paused subscription can be resumed");
      sub.status = SubscriptionStatus.pending;
    });
  }
}
