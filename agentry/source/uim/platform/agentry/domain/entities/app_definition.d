/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.entities.app_definition;

import uim.platform.agentry;

// mixin(ShowModule!());

@safe:

/// Metadata-driven application definition — the core Agentry concept describing
/// screens, fields, actions, transmissions, and business rules in a structured format.
struct AppDefinition {
    mixin TenantEntity!AppDefinitionId;

    MobileApplicationId applicationId;
    string name;
    string description;
    DefinitionStatus status = DefinitionStatus.draft;
    string definitionContent; // XML/JSON metadata payload
    string definitionFormat; // xml, json
    string schemaVersion;
    UserId authoredBy;
    string targetPlatform;
    string businessObjectModel; // linked backend BOM
    bool validationPassed;
    string validationErrors;
    long publishedAt;

    Json toJson() const {
        auto j = entityToJson
            .set("applicationId", applicationId.value)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("definitionFormat", definitionFormat)
            .set("schemaVersion", schemaVersion)
            .set("authoredBy", authoredBy.value)
            .set("targetPlatform", targetPlatform)
            .set("businessObjectModel", businessObjectModel)
            .set("validationPassed", validationPassed)
            .set("validationErrors", validationErrors)
            .set("publishedAt", publishedAt);
        return j;
    }
}
