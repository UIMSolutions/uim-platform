/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.subscriptions;
// import uim.platform.management.domain.entities.subscription;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Port: outgoing — subscription persistence.
interface SubscriptionRepository : ITenantRepository!(Subscription, SubscriptionId) {

  Subscription[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  Subscription[] findByApp(TenantId tenantId, SubaccountId subaccountId, string appName);
  Subscription[] findByStatus(TenantId tenantId, SubaccountId subaccountId, SubscriptionStatus status);
  
}
