/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.usecases.subscriptions;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage SaaS application subscriptions.
interface IManageSubscriptionsUseCase { 

  CommandResult createSubscription(CreateSubscriptionRequest request);
  CommandResult unsubscribeSubscription(TenantId tenantId, SubscriptionId id);
  CommandResult updateSubscriptionPlan(UpdateSubscriptionRequest req);
  Subscription getSubscription(TenantId tenantId, SubscriptionId id);
  Subscription[] listSubscriptions(TenantId tenantId, SubaccountId subId);

}
