/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.dev_space;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

struct DevSpace {
    mixin TenantEntity!(DevSpaceId);

    string name;
    string description;
    DevSpaceStatus status = DevSpaceStatus.stopped;
    DevSpacePlan plan = DevSpacePlan.standard;
    DevSpaceTypeId devSpaceTypeId;
    string extensions;
    string owner;
    string region;
    string lastAccessedAt;
    string hibernateAfterDays;
    string memoryLimit;
    string diskLimit;
    
    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("plan", plan.to!string)
            .set("devSpaceTypeId", devSpaceTypeId)
            .set("extensions", extensions)
            .set("owner", owner)
            .set("region", region)
            .set("lastAccessedAt", lastAccessedAt)
            .set("hibernateAfterDays", hibernateAfterDays)
            .set("memoryLimit", memoryLimit)
            .set("diskLimit", diskLimit);

        return j;
    }
}
