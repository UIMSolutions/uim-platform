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
}

struct Span {
  SpanId id;
  TenantId tenantId;
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
}
