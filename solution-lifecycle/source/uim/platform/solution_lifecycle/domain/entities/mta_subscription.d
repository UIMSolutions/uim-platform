/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.domain.entities.mta_subscription;

import uim.platform.solution_lifecycle;

// mixin(ShowModule!());

@safe:

/// A subscription record: a subaccount subscribing to a provided MTA solution.
class MtaSubscription {
    mixin TenantEntity!(MtaSubscriptionId);

    string             mtaId;            /// The provided solution's MTA app ID
    string             mtaVersion;
    string             providerTenantId; /// Tenant that provides the solution
    string             providerSpaceId;  /// Provider subaccount/space
    SubscriptionStatus subscriptionStatus;
    string             subscribedBy;
    string             extensionDescriptor; /// Optional extension YAML for subscriber
    string             lastOperationId;
    long               subscribedAt;
    long               unsubscribedAt;

    Json toJson() {
        auto j = Json.emptyObject;
        j["id"]                  = id.value;
        j["tenantId"]            = tenantId;
        j["mtaId"]               = mtaId;
        j["mtaVersion"]          = mtaVersion;
        j["providerTenantId"]    = providerTenantId;
        j["providerSpaceId"]     = providerSpaceId;
        j["subscriptionStatus"]  = subscriptionStatus.to!string;
        j["subscribedBy"]        = subscribedBy;
        j["lastOperationId"]     = lastOperationId;
        j["subscribedAt"]        = subscribedAt;
        j["unsubscribedAt"]      = unsubscribedAt;
        j["createdAt"]           = createdAt;
        j["updatedAt"]           = updatedAt;
        return j;
    }

    bool isNull() { return id.value.length == 0; }
}
