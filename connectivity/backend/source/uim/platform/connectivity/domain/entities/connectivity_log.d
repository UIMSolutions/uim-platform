/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.entities.connectivity_log;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// An immutable entry of the connectivity event log (audit / monitoring).
struct ConnectivityLogEntry {
  mixin TenantEntity!LogEntryId;

  string name; /// short title, e.g. "channelOpened · ERP_HTTP"
  ConnectivityEventType eventType;
  LogSeverity severity = LogSeverity.info;
  SourceType sourceType = SourceType.service;
  string sourceId;
  string sourceName;
  string message;
  string remoteHost;
  int remotePort;
  long occurredAt;
}
