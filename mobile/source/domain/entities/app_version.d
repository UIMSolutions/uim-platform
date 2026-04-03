/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.app_version;

import uim.platform.mobile.domain.types;

/// A specific version of a mobile app with OTA update support.
struct AppVersion
{
  AppVersionId id;
  MobileAppId appId;
  TenantId tenantId;
  string versionNumber; // semantic versioning e.g. "2.3.1"
  int buildNumber;
  MobilePlatform platform;
  VersionStatus status = VersionStatus.development;
  UpdatePolicy updatePolicy = UpdatePolicy.optional;
  string releaseNotes;
  string downloadUrl;
  long binarySize; // bytes
  string checksum; // SHA-256
  string minimumOsVersion;
  string[] requiredPermissions;
  bool forceUpdate = false;
  string releasedBy;
  long releasedAt;
  long createdAt;
}
