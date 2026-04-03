/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.types;

/// Unique identifier type aliases for type safety.
alias MobileAppId = string;
alias AppVersionId = string;
alias DeviceRegistrationId = string;
alias PushNotificationId = string;
alias PushTemplateId = string;
alias PushCampaignId = string;
alias OfflineConfigId = string;
alias SyncSessionId = string;
alias FeatureToggleId = string;
alias SecurityPolicyId = string;
alias UsageEventId = string;
alias ClientLogId = string;
alias TenantId = string;

/// Mobile platform type.
enum MobilePlatform
{
  ios,
  android,
  windows,
  webApp,
}

/// Status of a mobile app definition.
enum AppStatus
{
  draft,
  active,
  suspended,
  deprecated_,
  retired,
}

/// Authentication type for mobile apps.
enum MobileAuthType
{
  oauth2,
  saml,
  basicAuth,
  certificateBased,
  biometric,
  apiKey,
  noAuth,
}

/// App version release status.
enum VersionStatus
{
  development,
  beta,
  releaseCandidate,
  released,
  mandatory,
  superseded,
  revoked,
}

/// Update enforcement policy.
enum UpdatePolicy
{
  optional,
  recommended,
  forced,
  blockedBelow,
}

/// Push notification priority.
enum PushPriority
{
  low,
  normal,
  high,
  critical,
}

/// Push notification status.
enum PushStatus
{
  pending,
  sent,
  delivered,
  failed,
  expired,
  cancelled,
}

/// Push campaign status.
enum CampaignStatus
{
  draft,
  scheduled,
  active,
  paused,
  completed,
  cancelled,
}

/// Device registration status.
enum DeviceStatus
{
  registered,
  active,
  inactive,
  blocked,
  deregistered,
}

/// Offline sync strategy.
enum SyncStrategy
{
  fullSync,
  deltaSync,
  onDemand,
  backgroundSync,
}

/// Conflict resolution policy for offline sync.
enum ConflictResolution
{
  clientWins,
  serverWins,
  lastWriteWins,
  manual,
  merge,
}

/// Sync session status.
enum SyncSessionStatus
{
  started,
  inProgress,
  completed,
  failed,
  conflicted,
  cancelled,
}

/// Feature toggle status.
enum ToggleStatus
{
  enabled,
  disabled,
  percentage,
  userSegment,
  scheduled,
}

/// Security policy enforcement level.
enum EnforcementLevel
{
  optional,
  recommended,
  required,
  strict,
}

/// Usage event type.
enum UsageEventType
{
  appLaunch,
  screenView,
  userAction,
  apiCall,
  crash,
  performanceMetric,
  backgroundTask,
  pushReceived,
  syncCompleted,
}

/// Severity for client logs.
enum LogSeverity
{
  debug_,
  info,
  warning,
  error,
  fatal,
}
