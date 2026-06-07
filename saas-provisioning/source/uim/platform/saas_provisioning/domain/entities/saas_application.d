/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.domain.entities.saas_application;

import uim.platform.saas_provisioning;

// mixin(ShowModule!());

@safe:

/// Callback URLs registered together with a multitenant SaaS application.
/// These endpoints are invoked by the provisioning service on lifecycle events.
struct AppUrls {
    string onSubscriptionUrl;   /// POST — called when a consumer subscribes
    string onUnsubscriptionUrl; /// DELETE — called when a consumer unsubscribes
    string onUpdateUrl;         /// PUT — called when a subscription is updated
    string getDependenciesUrl;  /// GET — returns dependent service instances
    string appBaseUrl;          /// Base URL template; {subdomain} is replaced per consumer

    Json toJson() const @safe {
        auto j = Json.emptyObject;
        j["onSubscriptionUrl"]   = Json(onSubscriptionUrl);
        j["onUnsubscriptionUrl"] = Json(onUnsubscriptionUrl);
        j["onUpdateUrl"]         = Json(onUpdateUrl);
        j["getDependenciesUrl"]  = Json(getDependenciesUrl);
        j["appBaseUrl"]          = Json(appBaseUrl);
        return j;
    }
}

/// A multitenant application registered with the SaaS Provisioning Service.
/// Maps to a saas-registry service instance of plan type "application".
class SaasApplication {
    mixin TenantEntity!(SaasApplicationId);

    string                appName;            /// Unique technical identifier (per provider tenant)
    string                displayName;        /// Human-readable marketplace name
    string                description;
    string                category;           /// Marketplace grouping category
    AppUrls               appUrls;
    string                providerSubaccountId;
    string                globalAccountId;
    string                xsuaaServiceInstanceId;
    AppPlan               plan;
    AppRegistrationStatus status;
    string[]              dependencies;       /// Technical names of apps this app depends on
    bool                  autoSubscribeGlobalAccounts;

    Json toJson() {
        
        auto j = Json.emptyObject;
        j["id"]                          = Json(id.value);
        j["tenantId"]                    = Json(tenantId);
        j["appName"]                     = Json(appName);
        j["displayName"]                 = Json(displayName);
        j["description"]                 = Json(description);
        j["category"]                    = Json(category);
        j["appUrls"]                     = appUrls.toJson();
        j["providerSubaccountId"]        = Json(providerSubaccountId);
        j["globalAccountId"]             = Json(globalAccountId);
        j["xsuaaServiceInstanceId"]      = Json(xsuaaServiceInstanceId);
        j["plan"]                        = Json(plan.to!string);
        j["status"]                      = Json(status.to!string);
        j["autoSubscribeGlobalAccounts"] = Json(autoSubscribeGlobalAccounts);
        j["createdAt"]                   = Json(createdAt);
        j["updatedAt"]                   = Json(updatedAt);
        auto deps = Json.emptyArray;
        foreach (d; dependencies) deps ~= Json(d);
        j["dependencies"] = deps;
        return j;
    }

    bool isNull() { return id.value.length == 0; }
}
