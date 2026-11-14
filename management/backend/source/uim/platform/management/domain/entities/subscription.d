/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.subscription;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// A subscription represents a SaaS application that a subaccount
/// has subscribed to (multitenant application consumption).
struct Subscription {
  mixin TenantEntity!SubscriptionId;

  GlobalAccountId globalAccountId;
  SubaccountId subaccountId;
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
  long subscribedAt; // stdTime
  UserId subscribedBy;
  string[string] parameters;
  string[string] labels;

  /// True if the subscription blocks a new subscription to the same app.
  bool isLive() const {
    return status == SubscriptionStatus.subscribed || status == SubscriptionStatus.subscribing;
  }

  /// subscribed → unsubscribed
  void unsubscribe(UserId by) {
    if (status != SubscriptionStatus.subscribed)
      throw new InvalidStateTransition("Subscription", enumName(status), "be unsubscribed");
    status = SubscriptionStatus.unsubscribed;
    isSubscriptionDone = false;
    update(by);
  }

  Json toJson() const {
    return entityToJson()
      .set("globalAccountId", globalAccountId.value)
      .set("subaccountId", subaccountId.value)
      .set("appName", appName)
      .set("appDisplayName", appDisplayName)
      .set("appDescription", appDescription)
      .set("planName", planName)
      .set("commercialAppName", commercialAppName)
      .set("providerSubaccountId", providerSubaccountId)
      .set("status", enumName(status))
      .set("appUrl", appUrl)
      .set("isSubscriptionDone", isSubscriptionDone)
      .set("errorDescription", errorDescription)
      .set("dependentServices", listToJson(dependentServices))
      .set("subscribedAt", subscribedAt)
      .set("subscribedBy", subscribedBy.value)
      .set("parameters", propertiesToJson(parameters))
      .set("labels", propertiesToJson(labels));
  }
}

///
unittest {
  mixin(ShowTest!("Subscription"));

  // tenantId must come from the TenantEntity mixin (no shadowing field).
  auto s = Subscription(TenantId("t1"));
  assert(s.tenantId.value == "t1");
  s.status = SubscriptionStatus.subscribed;
  s.unsubscribe(UserId("u"));
  assert(s.status == SubscriptionStatus.unsubscribed && !s.isLive);
}
