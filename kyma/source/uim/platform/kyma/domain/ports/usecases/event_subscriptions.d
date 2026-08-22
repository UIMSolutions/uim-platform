/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.usecases.event_subscriptions;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for event subscription management.
interface IManageEventSubscriptionsUseCase {

  UsecaseResult createEventSubscription(CreateEventSubscriptionRequest req);

  UsecaseResult updateEventSubscription(TenantId tenantId, EventSubscriptionId subscriptionId, UpdateEventSubscriptionRequest request);

  UsecaseResult pauseEventSubscription(TenantId tenantId, EventSubscriptionId subscriptionId);

  UsecaseResult resumeEventSubscription(TenantId tenantId, EventSubscriptionId subscriptionId);

  bool hasSubscription(TenantId tenantId, EventSubscriptionId subscriptionId);

  EventSubscription getSubscription(TenantId tenantId, EventSubscriptionId subscriptionId);

  EventSubscription[] listByNamespace(TenantId tenantId, NamespaceId namespaceId);

  EventSubscription[] listByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId);

  UsecaseResult deleteSubscription(TenantId tenantId, EventSubscriptionId subscriptionId);

}
