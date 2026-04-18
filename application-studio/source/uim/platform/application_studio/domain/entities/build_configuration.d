/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.build_configuration;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

struct BuildConfiguration {
    BuildConfigurationId id;
    TenantId tenantId;
    ProjectId projectId;
    string name;
    string description;
    BuildStatus status = BuildStatus.pending;
    DeployTarget deployTarget = DeployTarget.cloudFoundry;
    string buildCommand;
    string deployCommand;
    string artifactPath;
    string mtaDescriptor;
    string lastBuildAt;
    string lastDeployAt;
    string buildLog;
    string createdAt;
    string modifiedAt;
    string createdBy;
    string modifiedBy;

    Json buildConfigurationToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("projectId", projectId)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("deployTarget", deployTarget.to!string)
            .set("buildCommand", buildCommand)
            .set("deployCommand", deployCommand)
            .set("artifactPath", artifactPath)
            .set("mtaDescriptor", mtaDescriptor)
            .set("lastBuildAt", lastBuildAt)
            .set("lastDeployAt", lastDeployAt)
            .set("buildLog", buildLog)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy);
    }
}
