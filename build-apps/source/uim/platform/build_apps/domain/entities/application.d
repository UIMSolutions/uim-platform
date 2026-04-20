/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.entities.application;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

struct Application {
    mixin TenantEntity!(ApplicationId);

    string name;
    string description;
    ApplicationType appType = ApplicationType.web;
    ApplicationStatus status = ApplicationStatus.draft;
    string version_;
    string iconUrl;
    string themeConfig;
    string globalVariables;
    string defaultLanguage;
    string supportedLanguages;
    string owner;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("appType", appType.to!string)
            .set("status", status.to!string)
            .set("version", version_)
            .set("iconUrl", iconUrl)
            .set("themeConfig", themeConfig)
            .set("globalVariables", globalVariables)
            .set("defaultLanguage", defaultLanguage)
            .set("supportedLanguages", supportedLanguages)
            .set("owner", owner);
    }
}
