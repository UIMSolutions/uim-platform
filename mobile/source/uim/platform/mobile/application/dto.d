/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.dto;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
// MobileApp DTOs
struct CreateMobileAppRequest {
  TenantId tenantId;
  string appId;

  string name;
  string description;
  string bundleId;
  string platform;
  string securityConfig;
  string authProvider;
  bool pushEnabled;
  bool offlineEnabled;
  string iconUrl;
  UserId createdBy;
}

struct UpdateMobileAppRequest {
  TenantId tenantId;
  MobileAppId appId;

  string description;
  string securityConfig;
  string authProvider;
  string status;
  bool pushEnabled;
  bool offlineEnabled;
  string iconUrl;
  UserId updatedBy;
}
// DeviceRegistration DTOs
struct RegisterDeviceRequest {
  TenantId tenantId;
  MobileAppId appId;
  string deviceModel;
  string osVersion;
  string appVersion;
  string platform;
  UserId userId;
  string deviceToken;
}

struct UpdateDeviceRequest {
  TenantId tenantId;
  string osVersion;
  string appVersion;
  string status;
  string deviceToken;
}
// PushNotification DTOs
struct SendPushNotificationRequest {
  TenantId tenantId;
  MobileAppId appId;
  string title;
  string body_;
  string payload;
  string provider;
  string priority;
  string[] targetDevices;
  string[] targetTopics;
  long scheduledAt;
  long expiresAt;
  UserId createdBy;
}
// PushRegistration DTOs
struct CreatePushRegistrationRequest {
  TenantId tenantId;
  MobileAppId appId;
  string deviceId;
  string provider;
  string pushToken;
  string[] topics;
}

struct UpdatePushRegistrationRequest {
  TenantId tenantId;
  string pushToken;
  string[] topics;
  string status;
}
// AppConfiguration DTOs
struct CreateAppConfigRequest {
  TenantId tenantId;
  MobileAppId appId;
  string key;
  string value;
  string description;
  bool isSecret;
  string platform;
  UserId createdBy;
  string dataType;
}

struct UpdateAppConfigRequest {
  TenantId tenantId;
  AppConfigurationId configId;
  string value;
  string description;
  UserId updatedBy;
}
// FeatureRestriction DTOs
struct CreateFeatureRestrictionRequest {
  TenantId tenantId;
  FeatureRestrictionId restrictionId;

  MobileAppId appId;
  string featureKey;
  string description;
  string type;
  bool enabled;
  int percentage;
  string[] whitelist;
  string metadata;
  UserId createdBy;
  UserId[] allowedUsers;
  string[] allowedDevices;
  string minAppVersion;
  string maxAppVersion;
  Date startDate;
  Date endDate;
}

struct UpdateFeatureRestrictionRequest {
  TenantId tenantId;
  FeatureRestrictionId restrictionId;
  string description;
  bool enabled;
  int percentage;
  string[] whitelist;
  string metadata;
  UserId updatedBy;
  UserId[] allowedUsers;
  string[] allowedDevices;
  string minAppVersion;
  string maxAppVersion;
  Date startDate;
  Date endDate;
}
// ClientResource DTOs
struct CreateClientResourceRequest {
  TenantId tenantId;
  ClientResourceId resourceId; // Optional, can be generated if not provided

  MobileAppId appId;
  string name;
  string description;
  string type;
  string contentType;
  string data;
  size_t sizeBytes;
  UserId createdBy;
  string minOsVersion;
  bool mandatory;
  long publishedAt;
  ulong version_;
  size_t checksum;
  string url;
}

struct UpdateClientResourceRequest {
  TenantId tenantId;
  ClientResourceId resourceId; // Required for update

  string description;
  string data;
  string contentType;
  size_t sizeBytes;
  UserId updatedBy;
  string minOsVersion;
  bool mandatory;
  long publishedAt;
  string version_;
  size_t checksum;
  string url;
}
// AppVersion DTOs
struct CreateAppVersionRequest {
  TenantId tenantId;
  MobileAppId appId;
  string versionCode;
  int buildNumber;
  string platform;
  string releaseNotes;
  string downloadUrl;
  size_t sizeBytes;
  UserId createdBy;
  string minOsVersion;
  bool mandatory;
  long releasedAt;
}

struct UpdateAppVersionRequest {
  TenantId tenantId;
  AppVersionId versionId;
  string status;
  string releaseNotes;
  string downloadUrl;
  string minOsVersion;
  bool mandatory;
  UserId updatedBy;
}
// UsageReport DTOs
struct ReportUsageRequest {
  TenantId tenantId;
  MobileAppId appId;
  string deviceId;
  UserId userId;
  string metricType;
  string metricKey;
  string metricValue;
  string sessionId;
  string platform;
  string appVersion;
  long timestamp;
}
// OfflineStore DTOs
struct CreateOfflineStoreRequest {
  TenantId tenantId;
  MobileAppId appId;
  string name;
  string serviceUrl;
  string definingRequests;
  string storeType;
  UserId createdBy;
}

struct UpdateOfflineStoreRequest {
  TenantId tenantId;
  MobileAppId appId;
  string serviceUrl;
  string definingRequests;
  string syncStatus;
}
// UserSession DTOs
struct CreateUserSessionRequest {
  TenantId tenantId;
  MobileAppId appId;
  string deviceId;
  UserId userId;
  string ipAddress;
  string userAgent;
  string platform;
  string appVersion;
}
// ClientLog DTOs
struct UploadClientLogRequest {
  TenantId tenantId;
  MobileAppId appId;
  string deviceId;
  UserId userId;
  string level;
  string source;
  string message;
  string stackTrace;
  string metadata;
  string platform;
  string appVersion;
  long timestamp;
  string context;
  string osVersion;
}
// Overview
struct OverviewSummary {
  long totalApps;
  long totalDevices;
  long totalPushNotifications;
  long totalPushRegistrations;
  long totalConfigurations;
  long totalFeatureFlags;
  long totalResources;
  long totalVersions;
  long totalUsageReports;
  long totalOfflineStores;
  long totalActiveSessions;
  long totalLogEntries;
}
