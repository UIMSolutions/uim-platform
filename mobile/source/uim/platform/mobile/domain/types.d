/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.types;

// ID aliases
struct MobileAppId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct DeviceRegistrationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct PushNotificationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct PushRegistrationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct AppConfigurationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct FeatureRestrictionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ClientResourceId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct AppVersionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct UsageReportId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct OfflineStoreId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct UserSessionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ClientLogEntryId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}


// Mobile app platform
enum AppPlatform {
  ios,
  android,
  windows,
  web,
}

// App status
enum AppStatus {
  active,
  inactive,
  suspended,
  deleted_,
}

// Device status
enum DeviceStatus {
  registered,
  locked,
  wiped,
  blocked,
}

// Push notification provider
enum PushProvider {
  apns,   // Apple Push Notification Service
  fcm,    // Firebase Cloud Messaging
  wns,    // Windows Notification Service
  w3c,    // W3C Web Push
}

// Notification status
enum NotificationStatus {
  pending,
  sent,
  delivered,
  failed,
  expired,
}

// Notification priority
enum NotificationPriority {
  low,
  normal,
  high,
}

// Push registration status
enum PushRegStatus {
  active,
  expired,
  revoked,
}

// Feature restriction type
enum RestrictionType {
  boolean_,   // on/off toggle
  percentage, // gradual rollout
  whitelist,  // specific users/devices
}

// Resource type
enum ClientResourceType {
  bundle,
  configuration,
  certificate,
  translation,
}

// Version status
enum VersionStatus {
  draft,
  published,
  mandatory,
  deprecated_,
  archived,
}

// Store type
enum OfflineStoreType {
  odata,
  custom,
}

// Store sync status
enum SyncStatus {
  idle,
  syncing,
  error,
  completed,
}

// Session status
enum SessionStatus {
  active,
  expired,
  terminated,
}

// Log level
enum LogLevel {
  debug_,
  info,
  warning,
  error,
  fatal,
}

// Log source
enum LogSource {
  client,
  server,
  push,
  sync,
}

// Usage metric type
enum MetricType {
  appLaunch,
  screenView,
  apiCall,
  pushReceived,
  syncCompleted,
  crash,
  custom,
}
