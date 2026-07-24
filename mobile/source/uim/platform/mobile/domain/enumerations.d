/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.enumerations;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

// Mobile app platform
enum AppPlatform {
  ios,
  android,
  windows,
  web,
  cross
}

AppPlatform toAppPlatform(string value) {
  mixin(EnumSwitch("AppPlatform", "cross"));
}

AppPlatform[] toAppPlatform(string[] values) {
  return values.map!(toAppPlatform).array;
}

string toString(AppPlatform value) {
  return value.to!string;
}

string[] toStrings(AppPlatform[] values) {
  return values.map!toString.array;
}
///
unittest {
  assert(toAppPlatform("ios") == AppPlatform.ios);
  assert(toAppPlatform("android") == AppPlatform.android);
  assert(toAppPlatform("windows") == AppPlatform.windows);
  assert(toAppPlatform("web") == AppPlatform.web);
  assert(toAppPlatform("cross") == AppPlatform.cross);

  assert(toAppPlatform("unknown") == AppPlatform.cross);
  assert(toAppPlatform("IOS") == AppPlatform.ios);
  assert(toAppPlatform("ANDROID") == AppPlatform.android);
  assert(toAppPlatform("WINDOWS") == AppPlatform.windows);
  assert(toAppPlatform("WEB") == AppPlatform.web);
  assert(toAppPlatform("CROSS") == AppPlatform.cross);

  assert(toAppPlatform("") == AppPlatform.cross);
  assert(toAppPlatform("UNKNOWN") == AppPlatform.cross);
}

// App status
enum AppStatus : string {
  active = "active",
  inactive = "inactive",
  suspended = "suspended",
  deleted_ = "deleted"
}

AppStatus toAppStatus(string value) {
  switch (value.toLower) {
  case "active":
    return AppStatus.active;
  case "inactive":
    return AppStatus.inactive;
  case "suspended":
    return AppStatus.suspended;
  case "deleted":
    return AppStatus.deleted_;
  default:
    return AppStatus.active;
  }
}

AppStatus[] toAppStatuses(string[] values) {
  return values.map!(toAppStatus).array;
}

string toString(AppStatus value) {
  return cast(string)value; // This will return the enum member name as a string, e.g., "active", "inactive", etc.
}

string[] toStrings(AppStatus[] values) {
  return values.map!toString.array;
}
///
unittest {
  assert(toAppStatus("active") == AppStatus.active);
  assert(toAppStatus("inactive") == AppStatus.inactive);
  assert(toAppStatus("suspended") == AppStatus.suspended);
  assert(toAppStatus("deleted") == AppStatus.deleted_);

  assert(toAppStatus("unknown") == AppStatus.active);
  assert(toAppStatus("ACTIVE") == AppStatus.active);
  assert(toAppStatus("INACTIVE") == AppStatus.inactive);
  assert(toAppStatus("SUSPENDED") == AppStatus.suspended);
  assert(toAppStatus("DELETED") == AppStatus.deleted_);

  assert(toAppStatus("") == AppStatus.active);
  assert(toAppStatus("UNKNOWN") == AppStatus.active);

  assert(toString(AppStatus.active) == "active");
  assert(toString(AppStatus.inactive) == "inactive");
  assert(toString(AppStatus.suspended) == "suspended");
  assert(toString(AppStatus.deleted_) == "deleted");
  assert(toStrings([
      AppStatus.active, AppStatus.inactive, AppStatus.suspended,
      AppStatus.deleted_
    ]) == ["active", "inactive", "suspended", "deleted"]);
  assert([
    AppStatus.active, AppStatus.inactive, AppStatus.suspended, AppStatus.deleted_
  ].toStrings == ["active", "inactive", "suspended", "deleted"]);
}

// Device status
enum DeviceStatus {
  registered,
  locked,
  wiped,
  blocked,
}

DeviceStatus toDeviceStatus(string value) {
  mixin(EnumSwitch("DeviceStatus", "registered"));
}

DeviceStatus[] toDeviceStatuses(string[] values) {
  return values.map!(toDeviceStatus).array;
}

string toString(DeviceStatus value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "registered", "locked", etc.
}

string[] toStrings(DeviceStatus[] values) {
  return values.map!toString.array;
}
///
unittest {
  assert(toDeviceStatus("registered") == DeviceStatus.registered);
  assert(toDeviceStatus("locked") == DeviceStatus.locked);
  assert(toDeviceStatus("wiped") == DeviceStatus.wiped);
  assert(toDeviceStatus("blocked") == DeviceStatus.blocked);
  assert(toDeviceStatus("unknown") == DeviceStatus.registered);
  assert(toDeviceStatus("REGISTERED") == DeviceStatus.registered);
  assert(toDeviceStatus("LOCKED") == DeviceStatus.locked);
  assert(toDeviceStatus("WIPED") == DeviceStatus.wiped);
  assert(toDeviceStatus("BLOCKED") == DeviceStatus.blocked);
  assert(toDeviceStatus("") == DeviceStatus.registered);
  assert(toDeviceStatus("UNKNOWN") == DeviceStatus.registered);

  assert(toString(DeviceStatus.registered) == "registered");
  assert(toString(DeviceStatus.locked) == "locked");
  assert(toString(DeviceStatus.wiped) == "wiped");
  assert(toString(DeviceStatus.blocked) == "blocked");

  assert(toStrings([
      DeviceStatus.registered, DeviceStatus.locked, DeviceStatus.wiped,
      DeviceStatus.blocked
    ]) == ["registered", "locked", "wiped", "blocked"]);
  assert([
    DeviceStatus.registered, DeviceStatus.locked, DeviceStatus.wiped,
    DeviceStatus.blocked
  ].toStrings == ["registered", "locked", "wiped", "blocked"]);
}

// Push notification provider
enum PushProvider {
  fcm, // Firebase Cloud Messaging
  apns, // Apple Push Notification Service
  wns, // Windows Notification Service
  w3c, // W3C Web Push
}

PushProvider toPushProvider(string value) {
  mixin(EnumSwitch("PushProvider", "fcm"));
}

PushProvider[] toPushProvider(string[] values) {
  return values.map!(toPushProvider).array;
}

string toString(PushProvider value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "fcm", "apns", etc.
}

string[] toStrings(PushProvider[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("PushProvider"));

  assert(toPushProvider("fcm") == PushProvider.fcm);
  assert(toPushProvider("apns") == PushProvider.apns);
  assert(toPushProvider("wns") == PushProvider.wns);
  assert(toPushProvider("w3c") == PushProvider.w3c);
  assert(toPushProvider("unknown") == PushProvider.fcm);
  assert(toPushProvider("FCM") == PushProvider.fcm);
  assert(toPushProvider("APNS") == PushProvider.apns);
  assert(toPushProvider("WNS") == PushProvider.wns);
  assert(toPushProvider("W3C") == PushProvider.w3c);
  assert(toPushProvider("") == PushProvider.fcm);
  assert(toPushProvider("UNKNOWN") == PushProvider.fcm);

  assert(toString(PushProvider.fcm) == "fcm");
  assert(toString(PushProvider.apns) == "apns");
  assert(toString(PushProvider.wns) == "wns");
  assert(toString(PushProvider.w3c) == "w3c");

  assert(toStrings([
      PushProvider.fcm, PushProvider.apns, PushProvider.wns, PushProvider.w3c
    ]) == ["fcm", "apns", "wns", "w3c"]);
  assert([
    PushProvider.fcm, PushProvider.apns, PushProvider.wns, PushProvider.w3c
  ].toStrings == ["fcm", "apns", "wns", "w3c"]);
}

// Notification status
enum NotificationStatus {
  pending,
  sent,
  delivered,
  failed,
  expired,
}

NotificationStatus toNotificationStatus(string value) {
  mixin(EnumSwitch("NotificationStatus", "pending"));
}

NotificationStatus[] toNotificationStatuses(string[] values) {
  return values.map!(toNotificationStatus).array;
}

string toString(NotificationStatus value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "pending", "sent", etc.
}

string[] toStrings(NotificationStatus[] values) {
  return values.map!toString.array;
}
///
unittest {
  assert("pending".toNotificationStatus == NotificationStatus.pending);
  assert("sent".toNotificationStatus == NotificationStatus.sent);
  assert("delivered".toNotificationStatus == NotificationStatus.delivered);
  assert("failed".toNotificationStatus == NotificationStatus.failed);
  assert("expired".toNotificationStatus == NotificationStatus.expired);
  assert("unknown".toNotificationStatus == NotificationStatus.pending);
  assert("PENDING".toNotificationStatus == NotificationStatus.pending);
  assert("SENT".toNotificationStatus == NotificationStatus.sent);
  assert("DELIVERED".toNotificationStatus == NotificationStatus.delivered);
  assert("FAILED".toNotificationStatus == NotificationStatus.failed);
  assert("EXPIRED".toNotificationStatus == NotificationStatus.expired);

  assert("".toNotificationStatus == NotificationStatus.pending);
  assert("UNKNOWN".toNotificationStatus == NotificationStatus.pending);

  assert(NotificationStatus.pending.toString == "pending");
  assert(NotificationStatus.sent.toString == "sent");
  assert(NotificationStatus.delivered.toString == "delivered");
  assert(NotificationStatus.failed.toString == "failed");
  assert(NotificationStatus.expired.toString == "expired");

  assert([
    NotificationStatus.pending, NotificationStatus.sent,
    NotificationStatus.delivered, NotificationStatus.failed,
    NotificationStatus.expired
  ].toStrings == ["pending", "sent", "delivered", "failed", "expired"]);
}

// Notification priority
enum NotificationPriority {
  normal,
  low,
  high,
}

NotificationPriority toNotificationPriority(string value) {
  mixin(EnumSwitch("NotificationPriority", "normal"));
}

NotificationPriority[] toNotificationPriorities(string[] values)
  => values.map!(toNotificationPriority).array;

string toString(NotificationPriority value)
  => value.to!string; // This will return the enum member name as a string, e.g., "normal", "low", etc.

string[] toStrings(NotificationPriority[] values)
  => values.map!toString.array;

///
unittest {
  assert("normal".toNotificationPriority == NotificationPriority.normal);
  assert("low".toNotificationPriority == NotificationPriority.low);
  assert("high".toNotificationPriority == NotificationPriority.high);
  assert("NORMAL".toNotificationPriority == NotificationPriority.normal);
  assert("LOW".toNotificationPriority == NotificationPriority.low);
  assert("HIGH".toNotificationPriority == NotificationPriority.high);

  assert("".toNotificationPriority == NotificationPriority.normal);
  assert("unknown".toNotificationPriority == NotificationPriority.normal);
  assert("UNKNOWN".toNotificationPriority == NotificationPriority.normal);

  assert(NotificationPriority.normal.toString == "normal");
  assert(NotificationPriority.low.toString == "low");
  assert(NotificationPriority.high.toString == "high");

  assert([
    NotificationPriority.normal, NotificationPriority.low,
    NotificationPriority.high
  ].toStrings == ["normal", "low", "high"]);
  assert([
    NotificationPriority.normal, NotificationPriority.low,
    NotificationPriority.high
  ].toStrings == ["normal", "low", "high"]);
}

// Push registration status
enum PushRegStatus {
  active,
  expired,
  revoked,
}

PushRegStatus toPushRegStatus(string value) {
  mixin(EnumSwitch("PushRegStatus", "active"));
}

PushRegStatus[] toPushRegStatuses(string[] values) {
  return values.map!(toPushRegStatus).array;
}

string toString(PushRegStatus value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "active", "expired", etc.
}

string[] toStrings(PushRegStatus[] values) {
  return values.map!toString.array;
}
///
unittest {
  assert(toPushRegStatus("active") == PushRegStatus.active);
  assert(toPushRegStatus("expired") == PushRegStatus.expired);
  assert(toPushRegStatus("revoked") == PushRegStatus.revoked);
  assert(toPushRegStatus("ACTIVE") == PushRegStatus.active);
  assert(toPushRegStatus("EXPIRED") == PushRegStatus.expired);
  assert(toPushRegStatus("REVOKED") == PushRegStatus.revoked);

  assert(toPushRegStatus("") == PushRegStatus.active);
  assert(toPushRegStatus("unknown") == PushRegStatus.active);
  assert(toPushRegStatus("UNKNOWN") == PushRegStatus.active);

  assert(toString(PushRegStatus.active) == "active");
  assert(toString(PushRegStatus.expired) == "expired");
  assert(toString(PushRegStatus.revoked) == "revoked");

  assert(toStrings([
      PushRegStatus.active, PushRegStatus.expired, PushRegStatus.revoked
    ]) == ["active", "expired", "revoked"]);
  assert(["active", "expired", "revoked"].toPushRegStatuses == [
      PushRegStatus.active, PushRegStatus.expired, PushRegStatus.revoked
    ]);
}

// Feature restriction type
enum RestrictionType : string {
  boolean_ = "boolean_", // on/off toggle
  percentage = "percentage", // gradual rollout
  whitelist = "whitelist", // specific users/devices
}

RestrictionType toRestrictionType(string value)
  => mixin(EnumSwitch("RestrictionType", "boolean_"));

RestrictionType[] toRestrictionTypes(string[] values)
  => values.map!(toRestrictionType).array;

string toString(RestrictionType value)
  => cast(string)value; // This will return the enum member name as a string, e.g., "boolean_", "percentage", etc.

string[] toStrings(RestrictionType[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("RestrictionType"));

  assert(toRestrictionType("boolean_") == RestrictionType.boolean_);
  assert(toRestrictionType("percentage") == RestrictionType.percentage);
  assert(toRestrictionType("whitelist") == RestrictionType.whitelist);
  assert(toRestrictionType("unknown") == RestrictionType.boolean_);
  assert(toRestrictionType("BOOLEAN_") == RestrictionType.boolean_);
  assert(toRestrictionType("PERCENTAGE") == RestrictionType.percentage);
  assert(toRestrictionType("WHITELIST") == RestrictionType.whitelist);

  assert(toRestrictionType("") == RestrictionType.boolean_);
  assert(toRestrictionType("UNKNOWN") == RestrictionType.boolean_);

  assert(toString(RestrictionType.boolean_) == "boolean_");
  assert(toString(RestrictionType.percentage) == "percentage");
  assert(toString(RestrictionType.whitelist) == "whitelist");

  assert(toStrings([
      RestrictionType.boolean_, RestrictionType.percentage,
      RestrictionType.whitelist
    ]) == ["boolean_", "percentage", "whitelist"]);
  assert([
    RestrictionType.boolean_, RestrictionType.percentage,
    RestrictionType.whitelist
  ].toStrings == ["boolean_", "percentage", "whitelist"]);
}

// Resource type
enum ClientResourceType {
  bundle,
  configuration,
  certificate,
  translation,
}

ClientResourceType toClientResourceType(string value) {
  mixin(EnumSwitch("ClientResourceType", "bundle"));
}

ClientResourceType[] toClientResourceTypes(string[] values)
  => values.map!(toClientResourceType).array;

string toString(ClientResourceType value)
  => value.to!string; // This will return the enum member name as a string, e.g., "bundle", "configuration", etc.

string[] toStrings(ClientResourceType[] values)
  => values.map!toString.array;

///
unittest {
  assert("bundle".toClientResourceType == ClientResourceType.bundle);
  assert("configuration".toClientResourceType == ClientResourceType.configuration);
  assert("certificate".toClientResourceType == ClientResourceType.certificate);
  assert("translation".toClientResourceType == ClientResourceType.translation);
  assert("unknown".toClientResourceType == ClientResourceType.bundle);
  assert("BUNDLE".toClientResourceType == ClientResourceType.bundle);
  assert("CONFIGURATION".toClientResourceType == ClientResourceType.configuration);
  assert("CERTIFICATE".toClientResourceType == ClientResourceType.certificate);
  assert("TRANSLATION".toClientResourceType == ClientResourceType.translation);

  assert("".toClientResourceType == ClientResourceType.bundle);
  assert("UNKNOWN".toClientResourceType == ClientResourceType.bundle);

  assert(ClientResourceType.bundle.toString == "bundle");
  assert(ClientResourceType.configuration.toString == "configuration");
  assert(ClientResourceType.certificate.toString == "certificate");
  assert(ClientResourceType.translation.toString == "translation");

  assert(["bundle", "configuration", "certificate", "translation"].toClientResourceTypes == [
      ClientResourceType.bundle, ClientResourceType.configuration,
      ClientResourceType.certificate, ClientResourceType.translation
    ]);
  assert([
    ClientResourceType.bundle, ClientResourceType.configuration,
    ClientResourceType.certificate, ClientResourceType.translation
  ].toStrings == ["bundle", "configuration", "certificate", "translation"]);
}

// Version status
enum VersionStatus : string {
  draft = "draft",
  published = "published",
  mandatory = "mandatory",
  deprecated_ = "deprecated",
  archived = "archived",
}

VersionStatus toVersionStatus(string value) {
  switch (value.toLower) {
  case "draft":
    return VersionStatus.draft;
  case "published":
    return VersionStatus.published;
  case "mandatory":
    return VersionStatus.mandatory;
  case "deprecated":
    return VersionStatus.deprecated_;
  case "archived":
    return VersionStatus.archived;
  default:
    return VersionStatus.draft;
  }
}

VersionStatus[] toVersionStatuses(string[] values) {
  return values.map!(toVersionStatus).array;
}

string toString(VersionStatus value) {
  return cast(string)value; // This will return the enum member name as a string, e.g., "draft", "published", etc.
}

string[] toStrings(VersionStatus[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("VersionStatus"));

  assert("draft".toVersionStatus == VersionStatus.draft);
  assert("published".toVersionStatus == VersionStatus.published);
  assert("mandatory".toVersionStatus == VersionStatus.mandatory);
  assert("deprecated".toVersionStatus == VersionStatus.deprecated_);
  assert("archived".toVersionStatus == VersionStatus.archived);
  assert("unknown".toVersionStatus == VersionStatus.draft);
  assert("DRAFT".toVersionStatus == VersionStatus.draft);
  assert("PUBLISHED".toVersionStatus == VersionStatus.published);
  assert("MANDATORY".toVersionStatus == VersionStatus.mandatory);
  assert("DEPRECATED".toVersionStatus == VersionStatus.deprecated_);
  assert("ARCHIVED".toVersionStatus == VersionStatus.archived);

  assert("".toVersionStatus == VersionStatus.draft);
  assert("UNKNOWN".toVersionStatus == VersionStatus.draft);

  assert(VersionStatus.draft.toString == "draft");
  assert(VersionStatus.published.toString == "published");
  assert(VersionStatus.mandatory.toString == "mandatory");
  assert(VersionStatus.deprecated_.toString == "deprecated");
  assert(VersionStatus.archived.toString == "archived");

  assert(toStrings([
      VersionStatus.draft, VersionStatus.published, VersionStatus.mandatory,
      VersionStatus.deprecated_, VersionStatus.archived
    ]) == ["draft", "published", "mandatory", "deprecated", "archived"]);
  assert([
    VersionStatus.draft, VersionStatus.published, VersionStatus.mandatory,
    VersionStatus.deprecated_, VersionStatus.archived
  ].toStrings == ["draft", "published", "mandatory", "deprecated", "archived"]);
}

// Store type
enum OfflineStoreType {
  odata,
  custom,
}

OfflineStoreType toOfflineStoreType(string value) {
  mixin(EnumSwitch("OfflineStoreType", "odata"));
}

OfflineStoreType[] toOfflineStoreTypes(string[] values) {
  return values.map!(toOfflineStoreType).array;
}

string toString(OfflineStoreType value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "odata", "custom", etc.
}

string[] toStrings(OfflineStoreType[] values) {
  return values.map!toString.array;
}
///
unittest {
  assert("odata".toOfflineStoreType == OfflineStoreType.odata);
  assert("custom".toOfflineStoreType == OfflineStoreType.custom);
  assert("unknown".toOfflineStoreType == OfflineStoreType.odata);
  assert("ODATA".toOfflineStoreType == OfflineStoreType.odata);
  assert("CUSTOM".toOfflineStoreType == OfflineStoreType.custom);

  assert("".toOfflineStoreType == OfflineStoreType.odata);
  assert("UNKNOWN".toOfflineStoreType == OfflineStoreType.odata);

  assert(OfflineStoreType.odata.toString == "odata");
  assert(OfflineStoreType.custom.toString == "custom");

  assert(["odata", "custom"].toOfflineStoreTypes == [
      OfflineStoreType.odata, OfflineStoreType.custom
    ]);
  assert([OfflineStoreType.odata, OfflineStoreType.custom].toStrings == [
      "odata", "custom"
    ]);
}

// Store sync status
enum SyncStatus {
  idle,
  syncing,
  error,
  completed,
}

SyncStatus toSyncStatus(string value) {
  mixin(EnumSwitch("SyncStatus", "idle"));
}

SyncStatus[] toSyncStatuses(string[] values)
  => values.map!(toSyncStatus).array;

string toString(SyncStatus value)
  => value.to!string; // This will return the enum member name as a string, e.g., "idle", "syncing", etc.

string[] toStrings(SyncStatus[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("SyncStatus"));

  assert("idle".toSyncStatus == SyncStatus.idle);
  assert("syncing".toSyncStatus == SyncStatus.syncing);
  assert("error".toSyncStatus == SyncStatus.error);
  assert("completed".toSyncStatus == SyncStatus.completed);

  assert("unknown".toSyncStatus == SyncStatus.idle);
  assert("IDLE".toSyncStatus == SyncStatus.idle);
  assert("SYNCING".toSyncStatus == SyncStatus.syncing);
  assert("ERROR".toSyncStatus == SyncStatus.error);
  assert("COMPLETED".toSyncStatus == SyncStatus.completed);

  assert("".toSyncStatus == SyncStatus.idle);
  assert("UNKNOWN".toSyncStatus == SyncStatus.idle);

  assert(SyncStatus.idle.toString == "idle");
  assert(SyncStatus.syncing.toString == "syncing");
  assert(SyncStatus.error.toString == "error");
  assert(SyncStatus.completed.toString == "completed");

  assert([
    SyncStatus.idle, SyncStatus.syncing, SyncStatus.error, SyncStatus.completed
  ].toStrings == ["idle", "syncing", "error", "completed"]);
  assert(["idle", "syncing", "error", "completed"].toSyncStatuses == [
      SyncStatus.idle, SyncStatus.syncing, SyncStatus.error, SyncStatus.completed
    ]);
}

// Session status
enum SessionStatus {
  active,
  expired,
  terminated,
}

SessionStatus toSessionStatus(string value) {
  mixin(EnumSwitch("SessionStatus", "active"));
}

SessionStatus[] toSessionStatuses(string[] values)
  => values.map!(toSessionStatus).array;

string toString(SessionStatus value)
  => value.to!string; // This will return the enum member name as a string, e.g., "active", "expired", etc.

string[] toStrings(SessionStatus[] values)
  => values.map!toString.array;

///
unittest {
  assert("active".toSessionStatus == SessionStatus.active);
  assert("expired".toSessionStatus == SessionStatus.expired);
  assert("terminated".toSessionStatus == SessionStatus.terminated);
  assert("unknown".toSessionStatus == SessionStatus.active);
  assert("ACTIVE".toSessionStatus == SessionStatus.active);
  assert("EXPIRED".toSessionStatus == SessionStatus.expired);
  assert("TERMINATED".toSessionStatus == SessionStatus.terminated);

  assert("".toSessionStatus == SessionStatus.active);
  assert("UNKNOWN".toSessionStatus == SessionStatus.active);

  assert(SessionStatus.active.toString == "active");
  assert(SessionStatus.expired.toString == "expired");
  assert(SessionStatus.terminated.toString == "terminated");

  assert(["active", "expired", "terminated"].toSessionStatuses == [
      SessionStatus.active, SessionStatus.expired, SessionStatus.terminated
    ]);
  assert([SessionStatus.active, SessionStatus.expired, SessionStatus.terminated].toStrings == [
      "active", "expired", "terminated"
    ]);
}

// Log source
enum LogSource {
  client,
  server,
  push,
  sync,
}

LogSource toLogSource(string value) {
  mixin(EnumSwitch("LogSource", "client"));
}

LogSource[] toLogSources(string[] values)
  => values.map!(toLogSource).array;

string toString(LogSource value)
  => value.to!string; // This will return the enum member name as a string, e.g., "client", "server", etc.

string[] toStrings(LogSource[] values)
  => values.map!toString.array;

///
unittest {
  assert("client".toLogSource == LogSource.client);
  assert("server".toLogSource == LogSource.server);
  assert("push".toLogSource == LogSource.push);
  assert("sync".toLogSource == LogSource.sync);
  assert("unknown".toLogSource == LogSource.client);
  assert("CLIENT".toLogSource == LogSource.client);
  assert("SERVER".toLogSource == LogSource.server);
  assert("PUSH".toLogSource == LogSource.push);
  assert("SYNC".toLogSource == LogSource.sync);

  assert("".toLogSource == LogSource.client);
  assert("UNKNOWN".toLogSource == LogSource.client);

  assert(LogSource.client.toString == "client");
  assert(LogSource.server.toString == "server");
  assert(LogSource.push.toString == "push");
  assert(LogSource.sync.toString == "sync");

  assert(toStrings([
      LogSource.client, LogSource.server, LogSource.push, LogSource.sync
    ]) == ["client", "server", "push", "sync"]);
  assert([LogSource.client, LogSource.server, LogSource.push, LogSource.sync].toStrings == [
      "client", "server", "push", "sync"
    ]);
}

// Usage metric type
enum MetricType {
  appLaunch, // App launch (e.g., for tracking app usage)
  screenView, // Screen view (e.g., for tracking screen views in the app)
  apiCall, // API call (e.g., for tracking API usage)
  pushReceived, // Push notification received (e.g., for tracking push notification open rate)
  syncCompleted, // Sync completed (e.g., offline store sync)
  crash, // Crash (e.g., for tracking app crashes)
  custom, // Custom metric (e.g., for tracking custom events)
}

MetricType toMetricType(string value) {
  mixin(EnumSwitch("MetricType", "appLaunch"));
}

MetricType[] toMetricTypes(string[] values) {
  return values.map!(toMetricType).array;
}

string toString(MetricType value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "appLaunch", "screenView", etc.
}

string[] toStrings(MetricType[] values) {
  return values.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("MetricType"));

  assert("appLaunch".toMetricType == MetricType.appLaunch);
  assert("screenView".toMetricType == MetricType.screenView);
  assert("apiCall".toMetricType == MetricType.apiCall);
  assert("pushReceived".toMetricType == MetricType.pushReceived);
  assert("syncCompleted".toMetricType == MetricType.syncCompleted);
  assert("crash".toMetricType == MetricType.crash);
  assert("custom".toMetricType == MetricType.custom);
  assert("unknown".toMetricType == MetricType.appLaunch);
  assert("APPLAUNCH".toMetricType == MetricType.appLaunch);
  assert("SCREENVIEW".toMetricType == MetricType.screenView);
  assert("APICALL".toMetricType == MetricType.apiCall);
  assert("PUSHRECEIVED".toMetricType == MetricType.pushReceived);
  assert("SYNCCOMPLETED".toMetricType == MetricType.syncCompleted);
  assert("CRASH".toMetricType == MetricType.crash);
  assert("CUSTOM".toMetricType == MetricType.custom);

  assert("".toMetricType == MetricType.appLaunch);
  assert("UNKNOWN".toMetricType == MetricType.appLaunch);

  assert(MetricType.appLaunch.toString == "appLaunch");
  assert(MetricType.screenView.toString == "screenView");
  assert(MetricType.apiCall.toString == "apiCall");
  assert(MetricType.pushReceived.toString == "pushReceived");
  assert(MetricType.syncCompleted.toString == "syncCompleted");
  assert(MetricType.crash.toString == "crash");
  assert(MetricType.custom.toString == "custom");

  assert(toStrings([
      MetricType.appLaunch, MetricType.screenView, MetricType.apiCall,
      MetricType.pushReceived, MetricType.syncCompleted, MetricType.crash,
      MetricType.custom
    ]) == [
    "appLaunch", "screenView", "apiCall", "pushReceived", "syncCompleted", "crash",
    "custom"
  ]);
  assert([
    MetricType.appLaunch, MetricType.screenView, MetricType.apiCall,
    MetricType.pushReceived, MetricType.syncCompleted, MetricType.crash,
    MetricType.custom
  ].toStrings == [
    "appLaunch", "screenView", "apiCall", "pushReceived", "syncCompleted", "crash",
    "custom"
  ]);
}

enum DataType : string {
  string_ = "string",
  integer = "integer",
  float_ = "float",
  boolean_ = "boolean",
  date = "date",
  datetime = "datetime",
  time = "time",
  binary = "binary",
  json = "json",
}

DataType toDataType(string value) {
  switch (value.toLower) {
  case "string":
    return DataType.string_;
  case "integer":
    return DataType.integer;
  case "float":
    return DataType.float_;
  case "boolean":
    return DataType.boolean_;
  case "date":
    return DataType.date;
  case "datetime":
    return DataType.datetime;
  case "time":
    return DataType.time;
  case "binary":
    return DataType.binary;
  case "json":
    return DataType.json;
  default:
    return DataType.string_;
  }
}

DataType[] toDataTypes(string[] values)
  => values.map!(toDataType).array;

string toString(DataType value)
  => cast(string)value; // This will return the enum member name as a string, e.g., "string", "integer", etc.

string[] toStrings(DataType[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("DataType"));

  assert("string".toDataType == DataType.string_);
  assert("integer".toDataType == DataType.integer);
  assert("float".toDataType == DataType.float_);
  assert("boolean".toDataType == DataType.boolean_);
  assert("date".toDataType == DataType.date);
  assert("datetime".toDataType == DataType.datetime);
  assert("time".toDataType == DataType.time);
  assert("binary".toDataType == DataType.binary);
  assert("json".toDataType == DataType.json);

  assert(toDataType("unknown") == DataType.string_);
  assert(toDataType("") == DataType.string_);

  assert(DataType.string_.toString == "string");
  assert(DataType.integer.toString == "integer");
  assert(DataType.float_.toString == "float");
  assert(DataType.boolean_.toString == "boolean");
  assert(DataType.date.toString == "date");
  assert(DataType.datetime.toString == "datetime");
  assert(DataType.time.toString == "time");
  assert(DataType.binary.toString == "binary");
  assert(DataType.json.toString == "json");

  assert([
    "string", "integer", "float", "boolean", "date", "datetime", "time", "binary",
    "json"
  ].toDataTypes == [
    DataType.string_, DataType.integer, DataType.float_, DataType.boolean_,
    DataType.date, DataType.datetime, DataType.time, DataType.binary,
    DataType.json
  ]);
  assert([
    DataType.string_, DataType.integer, DataType.float_, DataType.boolean_,
    DataType.date, DataType.datetime, DataType.time, DataType.binary,
    DataType.json
  ].toStrings == [
    "string", "integer", "float", "boolean", "date", "datetime", "time", "binary",
    "json"
  ]);
}
