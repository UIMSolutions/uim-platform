/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.application.dto;

import uim.platform.saas_provisioning;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Data transfer objects that cross the application boundary
// ---------------------------------------------------------------------------

struct RegisterAppRequest {
    string   appName;
    string   displayName;
    string   description;
    string   category;
    AppUrls  appUrls;
    string   providerSubaccountId;
    string   globalAccountId;
    string   xsuaaServiceInstanceId;
    AppPlan  plan;
    bool     autoSubscribeGlobalAccounts;
    string[] dependencies;
}

struct UpdateAppRequest {
    string   displayName;
    string   description;
    string   category;
    AppUrls  appUrls;
    AppPlan  plan;
    bool     autoSubscribeGlobalAccounts;
    string[] dependencies;
}

struct SubscribeRequest {
    string subscriberTenantId;
    string subscriberSubaccountId;
    string subscriberGlobalAccountId;
    string subdomain;
    string subscribedBy;
}

struct UpdateSubscriptionRequest {
    SubscriptionState state;
    string            error;
}
