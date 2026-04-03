/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.subscription;

// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// A subscription represents a SaaS application that a subaccount
/// has subscribed to (multitenant application consumption).
struct Subscription
{
  SubscriptionId id;
  SubaccountId subaccountId;
  GlobalAccountId globalAccountId;
  string appName; // technical name of the SaaS app
  string appDisplayName;
  string appDescription;
  string planName;
  string commercialAppName;
  string providerSubaccountId; // SaaS provider's subaccount
  SubscriptionStatus status = SubscriptionStatus.subscribing;
  string appUrl; // URL to the subscribed application
  string tenantId; // consumer tenant created for subscription
  bool isSubscriptionDone = false;
  string errorDescription;
  string[] dependentServices; // services required by this subscription
  long subscribedAt;
  long modifiedAt;
  string subscribedBy;
  string[string] parameters;
  string[string] labels;
}
