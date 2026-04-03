/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.entities.connectivity_log;

import uim.platform.connectivity.domain.types;

/// Immutable connectivity event log entry.
struct ConnectivityLog
{
  ConnectivityLogId id;
  TenantId tenantId;
  ConnectivityEventType eventType;
  LogSeverity severity = LogSeverity.info;
  string sourceId; // destination, connector, or channel ID
  string sourceType; // "Destination", "CloudConnector", "ServiceChannel", etc.
  string message;
  string remoteHost;
  ushort remotePort;
  long timestamp;
}
