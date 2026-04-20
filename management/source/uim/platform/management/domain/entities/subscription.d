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
struct Subscription {
  mixin TenantEntity!(SubscriptionId);

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
  bool isSubscriptionDone = false;
  string errorDescription;
  string[] dependentServices; // services required by this subscription
  long subscribedAt;
  string subscribedBy;
  string[string] parameters;
  string[string] labels;

  Json toJson() const {
      return entityToJson
          .set("subaccountId", subaccountId.value)
          .set("globalAccountId", globalAccountId.value)
          .set("appName", appName)
          .set("appDisplayName", appDisplayName)
          .set("appDescription", appDescription)
          .set("planName", planName)
          .set("commercialAppName", commercialAppName)
          .set("providerSubaccountId", providerSubaccountId)
          .set("status", status.to!string())
          .set("appUrl", appUrl)
          .set("isSubscriptionDone", isSubscriptionDone)
          .set("errorDescription", errorDescription)
          .set("dependentServices", dependentServices.array)
          .set("subscribedAt", subscribedAt)
          .set("subscribedBy", subscribedBy)
          .set("parameters", parameters)
          .set("labels", labels);
  }
}
