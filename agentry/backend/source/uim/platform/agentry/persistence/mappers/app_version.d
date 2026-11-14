/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.persistence.mappers.app_version;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// AppVersion ⇄ snapshot record.
struct AppVersionMapper {
  static Json toRecord(const AppVersion e) {
    auto r = baseRecord(e);
    r["mobileApplicationId"] = e.mobileApplicationId.value;
    r["definitionId"] = e.definitionId.value;
    r["versionNumber"] = e.versionNumber;
    r["releaseNotes"] = e.releaseNotes;
    r["status"] = enumValue(e.status);
    r["builtAt"] = e.builtAt;
    r["publishedAt"] = e.publishedAt;
    r["artifactUrl"] = e.artifactUrl;
    r["checksum"] = e.checksum;
    r["minOsVersion"] = e.minOsVersion;
    r["changeLog"] = e.changeLog;
    r["isMandatoryUpdate"] = e.isMandatoryUpdate;
    return r;
  }

  static AppVersion fromRecord(Json r) {
    AppVersion e;
    readBase(e, r);
    e.mobileApplicationId = MobileApplicationId(fieldString(r, "mobileApplicationId"));
    e.definitionId = AppDefinitionId(fieldString(r, "definitionId"));
    e.versionNumber = fieldString(r, "versionNumber");
    e.releaseNotes = fieldString(r, "releaseNotes");
    e.status = fieldEnum!AppVersionStatus(r, "status", AppVersionStatus.pending);
    e.builtAt = fieldLong(r, "builtAt");
    e.publishedAt = fieldLong(r, "publishedAt");
    e.artifactUrl = fieldString(r, "artifactUrl");
    e.checksum = fieldString(r, "checksum");
    e.minOsVersion = fieldString(r, "minOsVersion");
    e.changeLog = fieldString(r, "changeLog");
    e.isMandatoryUpdate = fieldBool(r, "isMandatoryUpdate");
    return e;
  }
}
