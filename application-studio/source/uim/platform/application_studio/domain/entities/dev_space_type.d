/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.dev_space_type;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

struct DevSpaceType {
    mixin TenantEntity!(DevSpaceTypeId);

    string name;
    string description;
    DevSpaceTypeCategory category = DevSpaceTypeCategory.predefined;
    string predefinedExtensions;
    string supportedProjectTypes;
    string runtimeStack;
    string iconUrl;
    
    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("category", category.to!string)
            .set("predefinedExtensions", predefinedExtensions)
            .set("supportedProjectTypes", supportedProjectTypes)
            .set("runtimeStack", runtimeStack)
            .set("iconUrl", iconUrl);

        return j;
    }
}
