/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.entities.app_build;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

struct AppBuild {
    AppBuildId id;
    TenantId tenantId;
    ApplicationId applicationId;
    string name;
    string description;
    BuildTarget buildTarget = BuildTarget.web;
    BuildStatus buildStatus = BuildStatus.pending;
    DeployStatus deployStatus = DeployStatus.notDeployed;
    string version_;
    string buildLog;
    string artifactUrl;
    string deployUrl;
    string buildConfig;
    string signingConfig;
    string lastBuildAt;
    string lastDeployAt;
    string createdAt;
    string modifiedAt;
    string createdBy;
    string modifiedBy;

    Json appBuildToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("applicationId", applicationId)
            .set("name", name)
            .set("description", description)
            .set("buildTarget", buildTarget.to!string)
            .set("buildStatus", buildStatus.to!string)
            .set("deployStatus", deployStatus.to!string)
            .set("version", version_)
            .set("buildLog", buildLog)
            .set("artifactUrl", artifactUrl)
            .set("deployUrl", deployUrl)
            .set("buildConfig", buildConfig)
            .set("signingConfig", signingConfig)
            .set("lastBuildAt", lastBuildAt)
            .set("lastDeployAt", lastDeployAt)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy);
    }
}
