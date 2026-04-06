/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.domain.entities.domain_mapping;

import uim.platform.custom_domain.domain.types;

struct DomainMapping {
    DomainMappingId id;
    TenantId tenantId;
    string customDomainId;
    string standardRoute;
    string customRoute;
    MappingType mappingType;
    MappingStatus status;
    string applicationName;
    string organizationId;
    string spaceId;
    string createdBy;
    long createdAt;
    long modifiedAt;
}
