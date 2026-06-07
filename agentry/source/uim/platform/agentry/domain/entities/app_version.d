/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.entities.app_version;

import uim.platform.agentry;

// mixin(ShowModule!());

@safe:

struct AppVersion {
    mixin TenantEntity!(AppVersionId);

    MobileApplicationId mobileApplicationId;
    AppDefinitionId definitionId;
    string versionNumber;     // e.g. "2.5.1"
    string releaseNotes;
    AppVersionStatus status = AppVersionStatus.pending;
    long builtAt;
    long publishedAt;
    string artifactUrl;
    string checksum;
    string minOsVersion;
    string changeLog;
    bool isMandatoryUpdate;

    Json toJson() const {
        auto j = entityToJson
            .set("mobileApplicationId", mobileApplicationId.value)
            .set("definitionId", definitionId.value)
            .set("versionNumber", versionNumber)
            .set("releaseNotes", releaseNotes)
            .set("status", status.to!string)
            .set("builtAt", builtAt)
            .set("publishedAt", publishedAt)
            .set("artifactUrl", artifactUrl)
            .set("checksum", checksum)
            .set("minOsVersion", minOsVersion)
            .set("changeLog", changeLog)
            .set("isMandatoryUpdate", isMandatoryUpdate);
        return j;
    }
}
