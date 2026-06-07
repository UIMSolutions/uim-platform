/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.domain.entities.app_subscription;

import uim.platform.saas_provisioning;

// mixin(ShowModule!());

@safe:

/// A consumer tenant's subscription to a multitenant SaaS application.
class AppSubscription {
    mixin TenantEntity!(AppSubscriptionId);

    string            appName;                   /// Technical name of the subscribed application
    string            appDisplayName;            /// Display name snapshot at subscription time
    string            subscriberTenantId;        /// Consumer subaccount tenant ID
    string            subscriberSubaccountId;
    string            subscriberGlobalAccountId;
    string            subdomain;                 /// Consumer subdomain (for URL resolution)
    string            consumerUrl;               /// Resolved consumer-specific application URL
    SubscriptionState state;
    string            subscribedBy;              /// User who initiated the subscription
    string            jobId;                     /// ID of the last async job for this subscription
    string            error;                     /// Last error message (when state == failed)

    Json toJson() {
        
        auto j = Json.emptyObject;
        j["id"]                        = Json(id.value);
        j["tenantId"]                  = Json(tenantId);
        j["appName"]                   = Json(appName);
        j["appDisplayName"]            = Json(appDisplayName);
        j["subscriberTenantId"]        = Json(subscriberTenantId);
        j["subscriberSubaccountId"]    = Json(subscriberSubaccountId);
        j["subscriberGlobalAccountId"] = Json(subscriberGlobalAccountId);
        j["subdomain"]                 = Json(subdomain);
        j["consumerUrl"]               = Json(consumerUrl);
        j["state"]                     = Json(state.to!string);
        j["subscribedBy"]              = Json(subscribedBy);
        j["jobId"]                     = Json(jobId);
        j["error"]                     = Json(error);
        j["createdAt"]                 = Json(createdAt);
        j["updatedAt"]                 = Json(updatedAt);
        return j;
    }

    bool isNull() { return id.value.length == 0; }
}
