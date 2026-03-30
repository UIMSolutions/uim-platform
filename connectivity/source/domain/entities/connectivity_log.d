module domain.entities.connectivity_log;

import domain.types;

/// Immutable connectivity event log entry.
struct ConnectivityLog
{
    ConnectivityLogId id;
    TenantId tenantId;
    ConnectivityEventType eventType;
    LogSeverity severity = LogSeverity.info;
    string sourceId;        // destination, connector, or channel ID
    string sourceType;      // "Destination", "CloudConnector", "ServiceChannel", etc.
    string message;
    string remoteHost;
    ushort remotePort;
    long timestamp;
}
