module uim.platform.mobile.application.dto;

import uim.platform.mobile.domain.types;

/// --- Command result ---

struct CommandResult
{
    bool success;
    string id;
    string error;
}

/// --- Mobile App DTOs ---

struct CreateMobileAppRequest
{
    TenantId tenantId;
    string name;
    string displayName;
    string description;
    string bundleId;
    string[] platforms;             // "ios", "android", "windows", "webApp"
    string authType;                // "oauth2", "saml", "basicAuth", etc.
    string iconUrl;
    string deepLinkScheme;
    bool pushEnabled;
    bool offlineEnabled;
    bool analyticsEnabled;
    bool loggingEnabled;
    SecurityPolicyId securityPolicyId;
    string backendUrl;
    string[string] customSettings;
    string createdBy;
}

struct UpdateMobileAppRequest
{
    string displayName;
    string description;
    string iconUrl;
    string deepLinkScheme;
    bool pushEnabled;
    bool offlineEnabled;
    bool analyticsEnabled;
    bool loggingEnabled;
    SecurityPolicyId securityPolicyId;
    string backendUrl;
    string[string] customSettings;
    string status;                  // "active", "suspended", "deprecated_"
}

/// --- App Version DTOs ---

struct CreateAppVersionRequest
{
    MobileAppId appId;
    TenantId tenantId;
    string versionNumber;
    int buildNumber;
    string platform;                // "ios", "android"
    string releaseNotes;
    string downloadUrl;
    long binarySize;
    string checksum;
    string minimumOsVersion;
    string[] requiredPermissions;
    string updatePolicy;            // "optional", "recommended", "forced"
    bool forceUpdate;
    string releasedBy;
}

/// --- Device Registration DTOs ---

struct RegisterDeviceRequest
{
    MobileAppId appId;
    TenantId tenantId;
    string userId;
    string deviceName;
    string platform;                // "ios", "android"
    string osVersion;
    string appVersion;
    string deviceModel;
    string pushToken;
    string locale;
    string timeZone;
    string[string] attributes;
}

struct UpdateDeviceRequest
{
    string pushToken;
    string osVersion;
    string appVersion;
    string locale;
    string timeZone;
    string[string] attributes;
}

/// --- Push Notification DTOs ---

struct SendPushRequest
{
    MobileAppId appId;
    TenantId tenantId;
    PushTemplateId templateId;
    string title;
    string body_;
    string imageUrl;
    string deepLink;
    string priority;                // "low", "normal", "high", "critical"
    string[] targetDeviceIds;
    string[] targetUserIds;
    string targetSegment;
    string[] targetPlatforms;
    string[string] customData;
    int badge;
    string sound;
    bool silent;
    long scheduledAt;
    string createdBy;
}

/// --- Push Template DTOs ---

struct CreatePushTemplateRequest
{
    MobileAppId appId;
    TenantId tenantId;
    string name;
    string titleTemplate;
    string bodyTemplate;
    string imageUrl;
    string deepLink;
    string defaultPriority;
    string[string] defaultData;
    string sound;
    bool silent;
    string locale;
    string createdBy;
}

/// --- Push Campaign DTOs ---

struct CreatePushCampaignRequest
{
    MobileAppId appId;
    TenantId tenantId;
    string name;
    string description;
    PushTemplateId templateId;
    string targetSegment;
    string[] targetPlatforms;
    long scheduledStartAt;
    long scheduledEndAt;
    string[string] templateVariables;
    string createdBy;
}

/// --- Offline Config DTOs ---

struct CreateOfflineConfigRequest
{
    MobileAppId appId;
    TenantId tenantId;
    string name;
    string description;
    string serviceUrl;
    string[] definingRequests;
    string syncStrategy;            // "fullSync", "deltaSync", "onDemand"
    string conflictResolution;      // "clientWins", "serverWins", "lastWriteWins"
    long maxStoreSize;
    int syncIntervalSeconds;
    bool encryptStore;
    bool compressData;
    bool enableDeltaTracking;
    string[] excludedEntities;
    int maxRetries;
    int retryDelaySeconds;
    string createdBy;
}

/// --- Sync Session DTOs ---

struct StartSyncSessionRequest
{
    OfflineConfigId offlineConfigId;
    MobileAppId appId;
    TenantId tenantId;
    string userId;
    string deviceId;
    string strategy;
    string deltaToken;
}

struct CompleteSyncSessionRequest
{
    long uploadedRecords;
    long downloadedRecords;
    long conflictCount;
    long resolvedConflicts;
    long uploadBytes;
    long downloadBytes;
    string deltaToken;
    string errorMessage;
    string status;                  // "completed", "failed", "conflicted"
}

/// --- Feature Toggle DTOs ---

struct CreateFeatureToggleRequest
{
    MobileAppId appId;
    TenantId tenantId;
    string key;
    string name;
    string description;
    string status;                  // "enabled", "disabled", "percentage"
    int rolloutPercentage;
    string[] enabledUserIds;
    string[] enabledSegments;
    string[] platforms;
    string minimumAppVersion;
    string defaultValue;
    string enabledValue;
    string variantJson;
    long scheduledEnableAt;
    long scheduledDisableAt;
    string createdBy;
}

struct EvaluateToggleRequest
{
    MobileAppId appId;
    string userId;
    string platform;
    string appVersion;
}

/// --- Security Policy DTOs ---

struct CreateSecurityPolicyRequest
{
    TenantId tenantId;
    string name;
    string description;
    string enforcementLevel;        // "optional", "recommended", "required", "strict"
    string[] allowedAuthTypes;
    int sessionTimeoutMinutes;
    int maxFailedLogins;
    bool requireBiometric;
    bool allowOfflineAccess;
    int offlineAccessDurationHours;
    bool encryptLocalStorage;
    bool preventScreenCapture;
    bool preventCopyPaste;
    bool enableDataLossPrevention;
    bool requireSsl;
    bool enableCertificatePinning;
    string[] pinnedCertificates;
    bool blockJailbroken;
    bool blockRooted;
    bool enableAppIntegrityCheck;
    string minimumOsVersion;
    string[] allowedIpRanges;
    string[] blockedCountries;
    bool enableAuditLogging;
    int logRetentionDays;
    string createdBy;
}

/// --- Usage Event DTOs ---

struct RecordUsageEventRequest
{
    MobileAppId appId;
    TenantId tenantId;
    string userId;
    string deviceId;
    string eventType;               // "appLaunch", "screenView", "crash", etc.
    string eventName;
    string screenName;
    string appVersion;
    string platform;
    long durationMs;
    string[string] properties;
    double responseTimeMs;
    long memoryUsageBytes;
    double cpuUsagePercent;
    double batteryLevel;
    string networkType;
}

/// --- Client Log DTOs ---

struct UploadClientLogRequest
{
    MobileAppId appId;
    TenantId tenantId;
    string userId;
    string deviceId;
    string severity;                // "debug_", "info", "warning", "error", "fatal"
    string message;
    string source;
    string stackTrace;
    string appVersion;
    string platform;
    string osVersion;
    string[string] context;
}

/// --- Analytics Summary ---

struct AppAnalyticsSummary
{
    long totalDevices;
    long activeDevices;
    long totalEvents;
    long crashCount;
    long pushSentCount;
    long pushDeliveredCount;
    long syncSessions;
    long failedSyncs;
}

/// --- Version Check Response ---

struct VersionCheckResponse
{
    bool updateAvailable;
    string latestVersion;
    string downloadUrl;
    string releaseNotes;
    bool forceUpdate;
}
