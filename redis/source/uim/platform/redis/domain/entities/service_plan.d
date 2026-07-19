/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.entities.service_plan;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

struct ServicePlan {
    mixin TenantEntity!(ServicePlanId);

    string name;
    string description;
    PlanTier tier;
    long memoryMb;
    long maxConnections;
    bool haEnabled;
    bool persistenceEnabled;
    bool tlsEnabled;
    string pricingUnit;
    bool available;

    Json toJson() const {
        return Json.emptyObject
            .set("id",                   id.value)
            .set("tenantId",             tenantId.value)
            .set("name",                 name)
            .set("description",          description)
            .set("tier",                 tier.to!string)
            .set("memoryMb",             memoryMb)
            .set("maxConnections",       maxConnections)
            .set("haEnabled",            haEnabled)
            .set("persistenceEnabled",   persistenceEnabled)
            .set("tlsEnabled",           tlsEnabled)
            .set("pricingUnit",          pricingUnit)
            .set("available",            available)
            .set("createdAt",            createdAt)
            .set("createdBy",            createdBy.value)
            .set("updatedBy",            updatedBy.value);
    }
}
