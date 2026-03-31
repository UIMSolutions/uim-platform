module domain.entities.client_log;

import domain.types;

/// A log entry uploaded from a mobile client.
struct ClientLog
{
    ClientLogId id;
    MobileAppId appId;
    TenantId tenantId;
    string userId;
    string deviceId;
    LogSeverity severity = LogSeverity.info;
    string message;
    string source;                  // module or class
    string stackTrace;              // for error/crash logs
    string appVersion;
    MobilePlatform platform;
    string osVersion;
    string[string] context;         // additional context
    long timestamp;
    long uploadedAt;
}
