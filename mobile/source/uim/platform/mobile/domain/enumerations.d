/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.enumerations;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:


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
  fcm,    // Firebase Cloud Messaging
  apns,   // Apple Push Notification Service
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
  normal,
  low,
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
