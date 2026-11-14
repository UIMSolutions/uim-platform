/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.usecases.event_subscriptions;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Eventing subscription lifecycle (requires the eventing module).
interface IManageEventSubscriptionsUseCase : IManageResource!(EventSubscription, EventSubscriptionId,
    CreateEventSubscriptionRequest, UpdateEventSubscriptionRequest) {
  UsecaseResult pause(TenantId tenantId, EventSubscriptionId id, UserId actor);
  UsecaseResult resume(TenantId tenantId, EventSubscriptionId id, UserId actor);
}
