/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.entities.service_plan;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

struct ServicePlan {
    mixin TenantEntity!(ServicePlanId);

    string name;
    string description;
    PlanTier tier;
    long memoryGb;
    long storageGb;
    long maxConnections;
    bool multiAzSupported;
    bool available;
    string pricingUnit;

    Json toJson() const {
        return Json.emptyObject
            .set("id",              id.value)
            .set("tenantId",        tenantId.value)
            .set("name",            name)
            .set("description",     description)
            .set("tier",            tier.to!string)
            .set("memoryGb",        memoryGb)
            .set("storageGb",       storageGb)
            .set("maxConnections",  maxConnections)
            .set("multiAzSupported", multiAzSupported)
            .set("available",       available)
            .set("pricingUnit",     pricingUnit)
            .set("createdAt",       createdAt)
            .set("createdBy",       createdBy.value)
            .set("updatedBy",       updatedBy.value);
    }
}
