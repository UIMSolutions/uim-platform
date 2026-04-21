/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.domain_mapping;

// import uim.platform.custom_domain.domain.types;
import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:
struct DomainMapping {
    mixin TenantEntity!(DomainMappingId);

    string customDomainId;
    string standardRoute;
    string customRoute;
    MappingType mappingType;
    MappingStatus status;
    string applicationName;
    string organizationId;
    string spaceId;
    
    Json toJson() const {
        auto j = entityToJson
            .set("customDomainId", customDomainId)
            .set("standardRoute", standardRoute)
            .set("customRoute", customRoute)
            .set("mappingType", mappingType.to!string)
            .set("status", status.to!string)
            .set("applicationName", applicationName)
            .set("organizationId", organizationId)
            .set("spaceId", spaceId);

        return j;
    }
}
