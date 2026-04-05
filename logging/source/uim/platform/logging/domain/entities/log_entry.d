/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.entities.log_entry;

// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct LogEntry {
  LogEntryId id;
  TenantId tenantId;
  LogStreamId streamId;
  long timestamp;
  LogLevel level = LogLevel.info;
  string source;
  string message;
  string[string] structuredData;
  TraceId traceId;
  SpanId spanId;
  string requestId;
  string correlationId;
  string componentName;
  string spaceName;
  string orgName;
  string resourceType;
  string resourceId;
  string[] tags;
}
