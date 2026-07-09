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
  return value.to!string();
}

string[] toString(AppPlatform[] values) {
  return values.map!(toString).array;
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

AppStatus[] toAppStatus(string[] values) {
  return values.map!(toAppStatus).array;
}

string toString(AppStatus value) {
  return cast(string)value; // This will return the enum member name as a string, e.g., "active", "inactive", etc.
}

string[] toString(AppStatus[] values) {
  return values.map!(toString).array;
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
  assert(toString([
      AppStatus.active, AppStatus.inactive, AppStatus.suspended,
      AppStatus.deleted_
    ]) == ["active", "inactive", "suspended", "deleted"]);
  assert([
    AppStatus.active, AppStatus.inactive, AppStatus.suspended, AppStatus.deleted_
  ].toString == ["active", "inactive", "suspended", "deleted"]);
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

DeviceStatus[] toDeviceStatus(string[] values) {
  return values.map!(toDeviceStatus).array;
}

string toString(DeviceStatus value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "registered", "locked", etc.
}

string[] toString(DeviceStatus[] values) {
  return values.map!(toString).array;
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

  assert(toString([
      DeviceStatus.registered, DeviceStatus.locked, DeviceStatus.wiped,
      DeviceStatus.blocked
    ]) == ["registered", "locked", "wiped", "blocked"]);
  assert([
    DeviceStatus.registered, DeviceStatus.locked, DeviceStatus.wiped,
    DeviceStatus.blocked
  ].toString == ["registered", "locked", "wiped", "blocked"]);
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

string[] toString(PushProvider[] values) {
  return values.map!(toString).array;
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

  assert(toString([
      PushProvider.fcm, PushProvider.apns, PushProvider.wns, PushProvider.w3c
    ]) == ["fcm", "apns", "wns", "w3c"]);
  assert([
    PushProvider.fcm, PushProvider.apns, PushProvider.wns, PushProvider.w3c
  ].toString == ["fcm", "apns", "wns", "w3c"]);
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

NotificationStatus[] toNotificationStatus(string[] values) {
  return values.map!(toNotificationStatus).array;
}

string toString(NotificationStatus value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "pending", "sent", etc.
}

string[] toString(NotificationStatus[] values) {
  return values.map!(toString).array;
}
///
unittest {
  assert(toNotificationStatus("pending") == NotificationStatus.pending);
  assert(toNotificationStatus("sent") == NotificationStatus.sent);
  assert(toNotificationStatus("delivered") == NotificationStatus.delivered);
  assert(toNotificationStatus("failed") == NotificationStatus.failed);
  assert(toNotificationStatus("expired") == NotificationStatus.expired);
  assert(toNotificationStatus("unknown") == NotificationStatus.pending);
  assert(toNotificationStatus("PENDING") == NotificationStatus.pending);
  assert(toNotificationStatus("SENT") == NotificationStatus.sent);
  assert(toNotificationStatus("DELIVERED") == NotificationStatus.delivered);
  assert(toNotificationStatus("FAILED") == NotificationStatus.failed);
  assert(toNotificationStatus("EXPIRED") == NotificationStatus.expired);

  assert(toNotificationStatus("") == NotificationStatus.pending);
  assert(toNotificationStatus("UNKNOWN") == NotificationStatus.pending);

  assert(toString(NotificationStatus.pending) == "pending");
  assert(toString(NotificationStatus.sent) == "sent");
  assert(toString(NotificationStatus.delivered) == "delivered");
  assert(toString(NotificationStatus.failed) == "failed");
  assert(toString(NotificationStatus.expired) == "expired");

  assert(toString([
      NotificationStatus.pending, NotificationStatus.sent,
      NotificationStatus.delivered, NotificationStatus.failed,
      NotificationStatus.expired
    ]) == ["pending", "sent", "delivered", "failed", "expired"]);
  assert([
    NotificationStatus.pending, NotificationStatus.sent,
    NotificationStatus.delivered, NotificationStatus.failed,
    NotificationStatus.expired
  ].toString == ["pending", "sent", "delivered", "failed", "expired"]);
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

NotificationPriority[] toNotificationPriority(string[] values) {
  return values.map!(toNotificationPriority).array;
}

string toString(NotificationPriority value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "normal", "low", etc.
}

string[] toString(NotificationPriority[] values) {
  return values.map!(toString).array;
}
///
unittest {
  assert(toNotificationPriority("normal") == NotificationPriority.normal);
  assert(toNotificationPriority("low") == NotificationPriority.low);
  assert(toNotificationPriority("high") == NotificationPriority.high);
  assert(toNotificationPriority("NORMAL") == NotificationPriority.normal);
  assert(toNotificationPriority("LOW") == NotificationPriority.low);
  assert(toNotificationPriority("HIGH") == NotificationPriority.high);

  assert(toNotificationPriority("") == NotificationPriority.normal);
  assert(toNotificationPriority("unknown") == NotificationPriority.normal);
  assert(toNotificationPriority("UNKNOWN") == NotificationPriority.normal);

  assert(toString(NotificationPriority.normal) == "normal");
  assert(toString(NotificationPriority.low) == "low");
  assert(toString(NotificationPriority.high) == "high");

  assert(toString([
      NotificationPriority.normal, NotificationPriority.low,
      NotificationPriority.high
    ]) == ["normal", "low", "high"]);
  assert([
    NotificationPriority.normal, NotificationPriority.low,
    NotificationPriority.high
  ].toString == ["normal", "low", "high"]);
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

PushRegStatus[] toPushRegStatus(string[] values) {
  return values.map!(toPushRegStatus).array;
}

string toString(PushRegStatus value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "active", "expired", etc.
}

string[] toString(PushRegStatus[] values) {
  return values.map!(toString).array;
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

  assert(toString([
      PushRegStatus.active, PushRegStatus.expired, PushRegStatus.revoked
    ]) == ["active", "expired", "revoked"]);
  assert([PushRegStatus.active, PushRegStatus.expired, PushRegStatus.revoked].toString == [
      "active", "expired", "revoked"
    ]);
}

// Feature restriction type
enum RestrictionType : string {
  boolean_ = "boolean_", // on/off toggle
  percentage = "percentage", // gradual rollout
  whitelist = "whitelist", // specific users/devices
}

RestrictionType toRestrictionType(string value) {
  mixin(EnumSwitch("RestrictionType", "boolean_"));
}

RestrictionType[] toRestrictionType(string[] values) {
  return values.map!(toRestrictionType).array;
}

string toString(RestrictionType value) {
  return cast(string)value; // This will return the enum member name as a string, e.g., "boolean_", "percentage", etc.
}

string[] toString(RestrictionType[] values) {
  return values.map!(toString).array;
}
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

  assert(toString([
      RestrictionType.boolean_, RestrictionType.percentage,
      RestrictionType.whitelist
    ]) == ["boolean_", "percentage", "whitelist"]);
  assert([
    RestrictionType.boolean_, RestrictionType.percentage,
    RestrictionType.whitelist
  ].toString == ["boolean_", "percentage", "whitelist"]);
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

ClientResourceType[] toClientResourceType(string[] values) {
  return values.map!(toClientResourceType).array;
}

string toString(ClientResourceType value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "bundle", "configuration", etc.
}

string[] toString(ClientResourceType[] values) {
  return values.map!(toString).array;
}
///
unittest {
  assert(toClientResourceType("bundle") == ClientResourceType.bundle);
  assert(toClientResourceType("configuration") == ClientResourceType.configuration);
  assert(toClientResourceType("certificate") == ClientResourceType.certificate);
  assert(toClientResourceType("translation") == ClientResourceType.translation);
  assert(toClientResourceType("unknown") == ClientResourceType.bundle);
  assert(toClientResourceType("BUNDLE") == ClientResourceType.bundle);
  assert(toClientResourceType("CONFIGURATION") == ClientResourceType.configuration);
  assert(toClientResourceType("CERTIFICATE") == ClientResourceType.certificate);
  assert(toClientResourceType("TRANSLATION") == ClientResourceType.translation);

  assert(toClientResourceType("") == ClientResourceType.bundle);
  assert(toClientResourceType("UNKNOWN") == ClientResourceType.bundle);

  assert(toString(ClientResourceType.bundle) == "bundle");
  assert(toString(ClientResourceType.configuration) == "configuration");
  assert(toString(ClientResourceType.certificate) == "certificate");
  assert(toString(ClientResourceType.translation) == "translation");

  assert(toString([
      ClientResourceType.bundle, ClientResourceType.configuration,
      ClientResourceType.certificate, ClientResourceType.translation
    ]) == ["bundle", "configuration", "certificate", "translation"]);
  assert([
    ClientResourceType.bundle, ClientResourceType.configuration,
    ClientResourceType.certificate, ClientResourceType.translation
  ].toString == ["bundle", "configuration", "certificate", "translation"]);
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

VersionStatus[] toVersionStatus(string[] values) {
  return values.map!(toVersionStatus).array;
}

string toString(VersionStatus value) {
  return cast(string)value; // This will return the enum member name as a string, e.g., "draft", "published", etc.
}

string[] toString(VersionStatus[] values) {
  return values.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("VersionStatus"));

  assert(toVersionStatus("draft") == VersionStatus.draft);
  assert(toVersionStatus("published") == VersionStatus.published);
  assert(toVersionStatus("mandatory") == VersionStatus.mandatory);
  assert(toVersionStatus("deprecated") == VersionStatus.deprecated_);
  assert(toVersionStatus("archived") == VersionStatus.archived);
  assert(toVersionStatus("unknown") == VersionStatus.draft);
  assert(toVersionStatus("DRAFT") == VersionStatus.draft);
  assert(toVersionStatus("PUBLISHED") == VersionStatus.published);
  assert(toVersionStatus("MANDATORY") == VersionStatus.mandatory);
  assert(toVersionStatus("DEPRECATED") == VersionStatus.deprecated_);
  assert(toVersionStatus("ARCHIVED") == VersionStatus.archived);

  assert(toVersionStatus("") == VersionStatus.draft);
  assert(toVersionStatus("UNKNOWN") == VersionStatus.draft);

  assert(toString(VersionStatus.draft) == "draft");
  assert(toString(VersionStatus.published) == "published");
  assert(toString(VersionStatus.mandatory) == "mandatory");
  assert(toString(VersionStatus.deprecated_) == "deprecated");
  assert(toString(VersionStatus.archived) == "archived");

  assert(toString([
      VersionStatus.draft, VersionStatus.published, VersionStatus.mandatory,
      VersionStatus.deprecated_, VersionStatus.archived
    ]) == ["draft", "published", "mandatory", "deprecated", "archived"]);
  assert([
    VersionStatus.draft, VersionStatus.published, VersionStatus.mandatory,
    VersionStatus.deprecated_, VersionStatus.archived
  ].toString == ["draft", "published", "mandatory", "deprecated", "archived"]);
}

// Store type
enum OfflineStoreType {
  odata,
  custom,
}

OfflineStoreType toOfflineStoreType(string value) {
  mixin(EnumSwitch("OfflineStoreType", "odata"));
}

OfflineStoreType[] toOfflineStoreType(string[] values) {
  return values.map!(toOfflineStoreType).array;
}

string toString(OfflineStoreType value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "odata", "custom", etc.
}

string[] toString(OfflineStoreType[] values) {
  return values.map!(toString).array;
}
///
unittest {
  assert(toOfflineStoreType("odata") == OfflineStoreType.odata);
  assert(toOfflineStoreType("custom") == OfflineStoreType.custom);
  assert(toOfflineStoreType("unknown") == OfflineStoreType.odata);
  assert(toOfflineStoreType("ODATA") == OfflineStoreType.odata);
  assert(toOfflineStoreType("CUSTOM") == OfflineStoreType.custom);

  assert(toOfflineStoreType("") == OfflineStoreType.odata);
  assert(toOfflineStoreType("UNKNOWN") == OfflineStoreType.odata);

  assert(toString(OfflineStoreType.odata) == "odata");
  assert(toString(OfflineStoreType.custom) == "custom");

  assert(toString([OfflineStoreType.odata, OfflineStoreType.custom]) == [
      "odata", "custom"
    ]);
  assert([OfflineStoreType.odata, OfflineStoreType.custom].toString == [
      "odata", "custom"
    ]);
  assert(["odata", "custom"].toOfflineStoreType == [
      OfflineStoreType.odata, OfflineStoreType.custom
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

SyncStatus[] toSyncStatus(string[] values) {
  return values.map!(toSyncStatus).array;
}

string toString(SyncStatus value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "idle", "syncing", etc.
}

string[] toString(SyncStatus[] values) {
  return values.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("SyncStatus"));

  assert(toSyncStatus("idle") == SyncStatus.idle);
  assert(toSyncStatus("syncing") == SyncStatus.syncing);
  assert(toSyncStatus("error") == SyncStatus.error);
  assert(toSyncStatus("completed") == SyncStatus.completed);

  assert(toSyncStatus("unknown") == SyncStatus.idle);
  assert(toSyncStatus("IDLE") == SyncStatus.idle);
  assert(toSyncStatus("SYNCING") == SyncStatus.syncing);
  assert(toSyncStatus("ERROR") == SyncStatus.error);
  assert(toSyncStatus("COMPLETED") == SyncStatus.completed);

  assert(toSyncStatus("") == SyncStatus.idle);
  assert(toSyncStatus("UNKNOWN") == SyncStatus.idle);

  assert(toString(SyncStatus.idle) == "idle");
  assert(toString(SyncStatus.syncing) == "syncing");
  assert(toString(SyncStatus.error) == "error");
  assert(toString(SyncStatus.completed) == "completed");

  assert(toString([
      SyncStatus.idle, SyncStatus.syncing, SyncStatus.error, SyncStatus.completed
    ]) == ["idle", "syncing", "error", "completed"]);
  assert([
    SyncStatus.idle, SyncStatus.syncing, SyncStatus.error, SyncStatus.completed
  ].toString == ["idle", "syncing", "error", "completed"]);
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

SessionStatus[] toSessionStatus(string[] values) {
  return values.map!(toSessionStatus).array;
}

string toString(SessionStatus value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "active", "expired", etc.
}

string[] toString(SessionStatus[] values) {
  return values.map!(toString).array;
}
///
unittest {
  assert(toSessionStatus("active") == SessionStatus.active);
  assert(toSessionStatus("expired") == SessionStatus.expired);
  assert(toSessionStatus("terminated") == SessionStatus.terminated);
  assert(toSessionStatus("unknown") == SessionStatus.active);
  assert(toSessionStatus("ACTIVE") == SessionStatus.active);
  assert(toSessionStatus("EXPIRED") == SessionStatus.expired);
  assert(toSessionStatus("TERMINATED") == SessionStatus.terminated);

  assert(toSessionStatus("") == SessionStatus.active);
  assert(toSessionStatus("UNKNOWN") == SessionStatus.active);

  assert(toString(SessionStatus.active) == "active");
  assert(toString(SessionStatus.expired) == "expired");
  assert(toString(SessionStatus.terminated) == "terminated");

  assert(toString([
      SessionStatus.active, SessionStatus.expired, SessionStatus.terminated
    ]) == ["active", "expired", "terminated"]);
  assert([SessionStatus.active, SessionStatus.expired, SessionStatus.terminated].toString == [
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

LogSource[] toLogSource(string[] values) {
  return values.map!(toLogSource).array;
}

string toString(LogSource value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "client", "server", etc.
}

string[] toString(LogSource[] values) {
  return values.map!(toString).array;
}
///
unittest {
  assert(toLogSource("client") == LogSource.client);
  assert(toLogSource("server") == LogSource.server);
  assert(toLogSource("push") == LogSource.push);
  assert(toLogSource("sync") == LogSource.sync);
  assert(toLogSource("unknown") == LogSource.client);
  assert(toLogSource("CLIENT") == LogSource.client);
  assert(toLogSource("SERVER") == LogSource.server);
  assert(toLogSource("PUSH") == LogSource.push);
  assert(toLogSource("SYNC") == LogSource.sync);

  assert(toLogSource("") == LogSource.client);
  assert(toLogSource("UNKNOWN") == LogSource.client);

  assert(toString(LogSource.client) == "client");
  assert(toString(LogSource.server) == "server");
  assert(toString(LogSource.push) == "push");
  assert(toString(LogSource.sync) == "sync");

  assert(toString([
      LogSource.client, LogSource.server, LogSource.push, LogSource.sync
    ]) == ["client", "server", "push", "sync"]);
  assert([LogSource.client, LogSource.server, LogSource.push, LogSource.sync].toString == [
      "client", "server", "push", "sync"
    ]);
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
MetricType toMetricType(string value) {
  mixin(EnumSwitch("MetricType", "appLaunch"));
}
MetricType[] toMetricType(string[] values) {
  return values.map!(toMetricType).array;
}
string toString(MetricType value) {
  return value.to!string; // This will return the enum member name as a string, e.g., "appLaunch", "screenView", etc.
}
string[] toString(MetricType[] values) {
  return values.map!(toString).array;
}
///
unittest {
  mixin (ShowTest!("MetricType"));

  assert(toMetricType("appLaunch") == MetricType.appLaunch);
  assert(toMetricType("screenView") == MetricType.screenView);
  assert(toMetricType("apiCall") == MetricType.apiCall);  
  assert(toMetricType("pushReceived") == MetricType.pushReceived);
  assert(toMetricType("syncCompleted") == MetricType.syncCompleted);
  assert(toMetricType("crash") == MetricType.crash);
  assert(toMetricType("custom") == MetricType.custom);
  assert(toMetricType("unknown") == MetricType.appLaunch);
  assert(toMetricType("APPLAUNCH") == MetricType.appLaunch);
  assert(toMetricType("SCREENVIEW") == MetricType.screenView);
  assert(toMetricType("APICALL") == MetricType.apiCall);
  assert(toMetricType("PUSHRECEIVED") == MetricType.pushReceived);
  assert(toMetricType("SYNCCOMPLETED") == MetricType.syncCompleted);
  assert(toMetricType("CRASH") == MetricType.crash);
  assert(toMetricType("CUSTOM") == MetricType.custom);  

  assert(toMetricType("") == MetricType.appLaunch);
  assert(toMetricType("UNKNOWN") == MetricType.appLaunch);

  assert(toString(MetricType.appLaunch) == "appLaunch");
  assert(toString(MetricType.screenView) == "screenView");
  assert(toString(MetricType.apiCall) == "apiCall");
  assert(toString(MetricType.pushReceived) == "pushReceived");
  assert(toString(MetricType.syncCompleted) == "syncCompleted");
  assert(toString(MetricType.crash) == "crash");
  assert(toString(MetricType.custom) == "custom");

  assert(toString([
      MetricType.appLaunch, MetricType.screenView, MetricType.apiCall,
      MetricType.pushReceived, MetricType.syncCompleted, MetricType.crash,
      MetricType.custom
    ]) == ["appLaunch", "screenView", "apiCall", "pushReceived", "syncCompleted", "crash", "custom"]);
  assert([
    MetricType.appLaunch, MetricType.screenView, MetricType.apiCall,
    MetricType.pushReceived, MetricType.syncCompleted, MetricType.crash,
    MetricType.custom
  ].toString == ["appLaunch", "screenView", "apiCall", "pushReceived", "syncCompleted", "crash", "custom"]);
}

enum Datatype : string {
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
Datatype toDatatype(string value) {
  switch(value.toLower) {
    case "string":
      return Datatype.string_;
    case "integer":
      return Datatype.integer;
    case "float":
      return Datatype.float_;
    case "boolean":
      return Datatype.boolean_;
    case "date":
      return Datatype.date;
    case "datetime":
      return Datatype.datetime;
    case "time":
      return Datatype.time;
    case "binary":
      return Datatype.binary;
    case "json":
      return Datatype.json;
    default:
      return Datatype.string_;
  }
}
Datatype[] toDatatype(string[] values) {
  return values.map!(toDatatype).array;
}
string toString(Datatype value) {
  return cast(string)value; // This will return the enum member name as a string, e.g., "string", "integer", etc.
}
string[] toString(Datatype[] values) {
  return values.map!(toString).array;
}
/// 
unittest { 
  mixin(ShowTest!("Datatype"));

  assert(toDatatype("string") == Datatype.string_);
  assert(toDatatype("integer") == Datatype.integer);
  assert(toDatatype("float") == Datatype.float_);
  assert(toDatatype("boolean") == Datatype.boolean_);
  assert(toDatatype("date") == Datatype.date);
  assert(toDatatype("datetime") == Datatype.datetime);
  assert(toDatatype("time") == Datatype.time);
  assert(toDatatype("binary") == Datatype.binary);
  assert(toDatatype("json") == Datatype.json);

  assert(toDatatype("unknown") == Datatype.string_);
  assert(toDatatype("") == Datatype.string_);

  assert(toString(Datatype.string_) == "string");
  assert(toString(Datatype.integer) == "integer");
  assert(toString(Datatype.float_) == "float");
  assert(toString(Datatype.boolean_) == "boolean");
  assert(toString(Datatype.date) == "date");
  assert(toString(Datatype.datetime) == "datetime");
  assert(toString(Datatype.time) == "time");
  assert(toString(Datatype.binary) == "binary");
  assert(toString(Datatype.json) == "json");
}