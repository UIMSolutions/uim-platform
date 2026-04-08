/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.dto;

// Generic command result
struct CommandResult {
  bool success;
  string id;
  string error;
}

// MobileApp DTOs
struct CreateMobileAppRequest {
  TenantId tenantId;
  string name;
  string description;
  string bundleId;
  string platform;
  string securityConfig;
  string authProvider;
  bool pushEnabled;
  bool offlineEnabled;
  string iconUrl;
  string createdBy;
}

struct UpdateMobileAppRequest {
  string description;
  string securityConfig;
  string authProvider;
  string status;
  bool pushEnabled;
  bool offlineEnabled;
  string iconUrl;
  string modifiedBy;
}

// DeviceRegistration DTOs
struct RegisterDeviceRequest {
  TenantId tenantId;
  string appId;
  string deviceModel;
  string osVersion;
  string appVersion;
  string platform;
  string userId;
  string deviceToken;
}

struct UpdateDeviceRequest {
  string osVersion;
  string appVersion;
  string status;
  string deviceToken;
}

// PushNotification DTOs
struct SendPushNotificationRequest {
  TenantId tenantId;
  string appId;
  string title;
  string body_;
  string payload;
  string provider;
  string priority;
  string[] targetDevices;
  string[] targetTopics;
  long scheduledAt;
  long expiresAt;
  string createdBy;
}

// PushRegistration DTOs
struct CreatePushRegistrationRequest {
  TenantId tenantId;
  string appId;
  string deviceId;
  string provider;
  string pushToken;
  string[] topics;
}

struct UpdatePushRegistrationRequest {
  string pushToken;
  string[] topics;
  string status;
}

// AppConfiguration DTOs
struct CreateAppConfigRequest {
  TenantId tenantId;
  string appId;
  string key;
  string value;
  string description;
  bool isSecret;
  string platform;
  string createdBy;
}

struct UpdateAppConfigRequest {
  string value;
  string description;
  string modifiedBy;
}

// FeatureRestriction DTOs
struct CreateFeatureRestrictionRequest {
  TenantId tenantId;
  string appId;
  string featureKey;
  string description;
  string type;
  bool enabled;
  int percentage;
  string[] whitelist;
  string metadata;
  string createdBy;
}

struct UpdateFeatureRestrictionRequest {
  string description;
  bool enabled;
  int percentage;
  string[] whitelist;
  string metadata;
  string modifiedBy;
}

// ClientResource DTOs
struct CreateClientResourceRequest {
  TenantId tenantId;
  string appId;
  string name;
  string description;
  string type;
  string contentType;
  string data;
  string createdBy;
}

struct UpdateClientResourceRequest {
  string description;
  string data;
  string contentType;
}

// AppVersion DTOs
struct CreateAppVersionRequest {
  TenantId tenantId;
  string appId;
  string versionCode;
  int buildNumber;
  string platform;
  string releaseNotes;
  string downloadUrl;
  long sizeBytes;
  string createdBy;
}

struct UpdateAppVersionRequest {
  string status;
  string releaseNotes;
  string downloadUrl;
}

// UsageReport DTOs
struct ReportUsageRequest {
  TenantId tenantId;
  string appId;
  string deviceId;
  string userId;
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
  string appId;
  string name;
  string serviceUrl;
  string definingRequests;
  string storeType;
  string createdBy;
}

struct UpdateOfflineStoreRequest {
  string serviceUrl;
  string definingRequests;
  string syncStatus;
}

// UserSession DTOs
struct CreateUserSessionRequest {
  TenantId tenantId;
  string appId;
  string deviceId;
  string userId;
  string ipAddress;
  string userAgent;
  string platform;
  string appVersion;
}

// ClientLog DTOs
struct UploadClientLogRequest {
  TenantId tenantId;
  string appId;
  string deviceId;
  string userId;
  string level;
  string source;
  string message;
  string stackTrace;
  string metadata;
  string platform;
  string appVersion;
  long timestamp;
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
