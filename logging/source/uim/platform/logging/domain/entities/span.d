/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.entities.span;

// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct SpanEvent {
  string name;
  long timestamp;
  string[string] attributes;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("timestamp", timestamp)
      .set("attributes", attributes);
  }
}

struct Span {
  mixin TenantEntity!(SpanId);
  
  TraceId traceId;
  SpanId parentSpanId;
  string operationName;
  string serviceName;
  long startTime;
  long endTime;
  long durationMs;
  SpanStatus status = SpanStatus.unset;
  SpanKind kind = SpanKind.internal;
  string[string] attributes;
  SpanEvent[] events;
  string[string] resourceAttributes;

  Json toJson() const {
    return Json.entityToJson
      .set("traceId", traceId)
      .set("parentSpanId", parentSpanId)
      .set("operationName", operationName)
      .set("serviceName", serviceName)
      .set("startTime", startTime)
      .set("endTime", endTime)
      .set("durationMs", durationMs)
      .set("status", status.to!string)
      .set("kind", kind.to!string)
      .set("attributes", attributes)
      .set("events", events.map!(e => e.toJson()).array)
      .set("resourceAttributes", resourceAttributes);
  }
}
