module uim.platform.xyz.domain.entities.app_version;

import domain.types;

/// A specific version of a mobile app with OTA update support.
struct AppVersion
{
    AppVersionId id;
    MobileAppId appId;
    TenantId tenantId;
    string versionNumber;           // semantic versioning e.g. "2.3.1"
    int buildNumber;
    MobilePlatform platform;
    VersionStatus status = VersionStatus.development;
    UpdatePolicy updatePolicy = UpdatePolicy.optional;
    string releaseNotes;
    string downloadUrl;
    long binarySize;                // bytes
    string checksum;                // SHA-256
    string minimumOsVersion;
    string[] requiredPermissions;
    bool forceUpdate = false;
    string releasedBy;
    long releasedAt;
    long createdAt;
}
