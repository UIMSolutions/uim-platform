/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.entities.data_entity;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

struct DataEntity {
    DataEntityId id;
    TenantId tenantId;
    ApplicationId applicationId;
    string name;
    string description;
    DataEntityStatus status = DataEntityStatus.draft;
    string fields;
    string primaryKey;
    string indexes;
    string validationRules;
    string defaultValues;
    string relations;
    string createdAt;
    string modifiedAt;
    string createdBy;
    string modifiedBy;

    Json dataEntityToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("applicationId", applicationId)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("fields", fields)
            .set("primaryKey", primaryKey)
            .set("indexes", indexes)
            .set("validationRules", validationRules)
            .set("defaultValues", defaultValues)
            .set("relations", relations)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy);
    }
}
