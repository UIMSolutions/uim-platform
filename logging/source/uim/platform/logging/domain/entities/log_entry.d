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
  mixin TenantEntity!(LogEntryId);

  LogStreamId streamId;
  long timestamp;
  LoggingLevel level = LoggingLevel.info;
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

  Json toJson() const {
      return entityToJson
          .set("streamId", streamId.value)
          .set("timestamp", timestamp)
          .set("level", level.to!string())
          .set("source", source)
          .set("message", message)
          .set("structuredData", structuredData)
          .set("traceId", traceId.value)
          .set("spanId", spanId.value)
          .set("requestId", requestId)
          .set("correlationId", correlationId)
          .set("componentName", componentName)
          .set("spaceName", spaceName)
          .set("orgName", orgName)
          .set("resourceType", resourceType)
          .set("resourceId", resourceId)
          .set("tags", tags.array);
  }
}
