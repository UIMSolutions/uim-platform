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
    mixin TenantEntity!(DataEntityId);

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

    Json toJson() const {
        return entityToJson
            .set("applicationId", applicationId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("fields", fields)
            .set("primaryKey", primaryKey)
            .set("indexes", indexes)
            .set("validationRules", validationRules)
            .set("defaultValues", defaultValues)
            .set("relations", relations);
    }
}
