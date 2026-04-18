/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.project;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

struct Project {
    ProjectId id;
    TenantId tenantId;
    DevSpaceId devSpaceId;
    string name;
    string description;
    ProjectType projectType = ProjectType.basic;
    ProjectStatus status = ProjectStatus.active;
    ProjectTemplateId templateId;
    string rootPath;
    string gitRepositoryUrl;
    string gitBranch;
    string namespace_;
    string createdAt;
    string modifiedAt;
    string createdBy;
    string modifiedBy;

    Json projectToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("devSpaceId", devSpaceId)
            .set("name", name)
            .set("description", description)
            .set("projectType", projectType.to!string)
            .set("status", status.to!string)
            .set("templateId", templateId)
            .set("rootPath", rootPath)
            .set("gitRepositoryUrl", gitRepositoryUrl)
            .set("gitBranch", gitBranch)
            .set("namespace", namespace_)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy);
    }
}
