/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.services.subscription;

import uim.platform.management;

mixin(ShowModule!());

@safe:

class SubscriptionApi : ISubscriptionApi {
  protected IManageSubscriptionsUseCase usecase;

  this(IManageSubscriptionsUseCase usecase) {
    this.usecase = usecase;
  }

  Json listSubscriptions(string tenantId, string subaccountId) {
    auto items = subaccountId.length > 0 ? usecase.listSubscriptions(tenant(tenantId), SubaccountId(subaccountId)) : usecase.listSubscriptions(tenant(tenantId));
    return collectionOf(items);
  }

  Json getSubscription(string tenantId, string _id) {
    auto id = _id;
    return entityOrNotFound(usecase.getSubscription(tenant(tenantId), SubscriptionId(id)), "Subscription");
  }
}
