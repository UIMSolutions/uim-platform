/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.entities.registered_application;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

struct RegisteredApplication {
    RegisteredApplicationId id;
    TenantId tenantId;
    string name;
    string description;
    ApplicationStatus status;
    string endpointUrl;
    string apiVersion;
    string[] dataCategoryIds;
    string[] purposeIds;
    string contactEmail;
    string contactName;
    string registeredBy;
    string modifiedBy;
    string registeredAt;
    string modifiedAt;
}
