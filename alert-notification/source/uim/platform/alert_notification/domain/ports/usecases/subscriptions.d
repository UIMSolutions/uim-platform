/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.domain.ports.usecases.subscriptions;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

interface IManageSubscriptionsUseCase {

    UsecaseResult createSubscription(TenantId tenantId, CreateSubscriptionRequest req);
    QueryResult getSubscription(TenantId tenantId, string id);

    QueryResult listSubscriptions(TenantId tenantId);

    UsecaseResult updateSubscription(TenantId tenantId, SubscriptionId id, UpdateSubscriptionRequest req);

    UsecaseResult deleteSubscription(TenantId tenantId, SubscriptionId id);
}
