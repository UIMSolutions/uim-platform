/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.project_template;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

struct ProjectTemplate {
    ProjectTemplateId id;
    TenantId tenantId;
    string name;
    string description;
    TemplateCategory category = TemplateCategory.general;
    ProjectType targetProjectType = ProjectType.basic;
    string version_;
    string requiredExtensions;
    string scaffoldConfig;
    string defaultFiles;
    string iconUrl;
    string createdAt;
    string modifiedAt;
    string createdBy;
    string modifiedBy;

    Json projectTemplateToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("name", name)
            .set("description", description)
            .set("category", category.to!string)
            .set("targetProjectType", targetProjectType.to!string)
            .set("version", version_)
            .set("requiredExtensions", requiredExtensions)
            .set("scaffoldConfig", scaffoldConfig)
            .set("defaultFiles", defaultFiles)
            .set("iconUrl", iconUrl)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy);
    }
}
