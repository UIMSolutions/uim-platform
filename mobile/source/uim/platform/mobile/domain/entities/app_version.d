/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.app_version;

import uim.platform.mobile.domain.types;

struct AppVersion {
  mixin TenantEntity!AppVersionId;

  MobileAppId appId;
  string versionCode;       // e.g. "2.1.0"
  int buildNumber;
  AppPlatform platform;
  VersionStatus status;
  string releaseNotes;
  string downloadUrl;
  long sizeBytes;
  long publishedAt;

  Json toJson() const {
    return entityToJson
      .set("appId", appId)
      .set("versionCode", versionCode)
      .set("buildNumber", buildNumber)
      .set("platform", platform.to!string)
      .set("status", status.to!string)
      .set("releaseNotes", releaseNotes)
      .set("downloadUrl", downloadUrl)
      .set("sizeBytes", sizeBytes)
      .set("publishedAt", publishedAt);
  }
}
