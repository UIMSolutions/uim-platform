/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.persistence.mappers.subscription;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Converts between Subscription and its snapshot record.
struct SubscriptionMapper {
  static Json toRecord(const Subscription e) {
    auto r = baseRecord(e);
    r["globalAccountId"] = e.globalAccountId.value;
    r["subaccountId"] = e.subaccountId.value;
    r["appName"] = e.appName;
    r["appDisplayName"] = e.appDisplayName;
    r["appDescription"] = e.appDescription;
    r["planName"] = e.planName;
    r["commercialAppName"] = e.commercialAppName;
    r["providerSubaccountId"] = e.providerSubaccountId;
    r["status"] = enumName(e.status);
    r["appUrl"] = e.appUrl;
    r["isSubscriptionDone"] = e.isSubscriptionDone;
    r["errorDescription"] = e.errorDescription;
    r["dependentServices"] = listToJson(e.dependentServices);
    r["subscribedAt"] = e.subscribedAt;
    r["subscribedBy"] = e.subscribedBy.value;
    r["parameters"] = propertiesToJson(e.parameters);
    r["labels"] = propertiesToJson(e.labels);
    return r;
  }

  static Subscription fromRecord(Json r) {
    Subscription e;
    readBase(e, r);
    e.globalAccountId = GlobalAccountId(fieldString(r, "globalAccountId"));
    e.subaccountId = SubaccountId(fieldString(r, "subaccountId"));
    e.appName = fieldString(r, "appName");
    e.appDisplayName = fieldString(r, "appDisplayName");
    e.appDescription = fieldString(r, "appDescription");
    e.planName = fieldString(r, "planName");
    e.commercialAppName = fieldString(r, "commercialAppName");
    e.providerSubaccountId = fieldString(r, "providerSubaccountId");
    e.status = fieldEnum!SubscriptionStatus(r, "status", SubscriptionStatus.subscribing);
    e.appUrl = fieldString(r, "appUrl");
    e.isSubscriptionDone = fieldBool(r, "isSubscriptionDone");
    e.errorDescription = fieldString(r, "errorDescription");
    e.dependentServices = fieldStrings(r, "dependentServices");
    e.subscribedAt = fieldLong(r, "subscribedAt");
    e.subscribedBy = UserId(fieldString(r, "subscribedBy"));
    e.parameters = fieldMap(r, "parameters");
    e.labels = fieldMap(r, "labels");
    return e;
  }
}
