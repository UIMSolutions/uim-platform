/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.entities.app_version;

// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
struct AppVersion {
  AppVersionId id;
  TenantId tenantId;
  HtmlAppId appId;
  string versionCode;       // semantic version e.g. "1.0.0"
  string description;
  VersionStatus status;
  long totalSizeBytes;
  int fileCount;
  long deployedAt;
  long createdAt;
  long updatedAt;
  string createdBy;
}
