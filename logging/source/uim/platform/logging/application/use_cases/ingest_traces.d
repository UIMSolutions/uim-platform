/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.ingest_traces;

import uim.platform.logging.domain.entities.span;
import uim.platform.logging.domain.ports.repositories.spans;
import uim.platform.logging.domain.types;
import uim.platform.logging.application.dto;

import std.conv : to;
import std.format : format;

class IngestTracesUseCase : UIMUseCase {
  private SpanRepository spanRepo;

  this(SpanRepository spanRepo) {
    this.spanRepo = spanRepo;
  }

  CommandResult ingestSpan(IngestSpanRequest req) {
    import std.uuid : randomUUID;

    Span s;
    s.id = randomUUID().to!string;
    s.tenantId = req.tenantId;
    s.traceId = req.traceId;
    s.parentSpanId = req.parentSpanId;
    s.operationName = req.operationName;
    s.serviceName = req.serviceName;
    s.startTime = req.startTime;
    s.endTime = req.endTime;
    s.durationMs = (req.endTime > req.startTime) ? (req.endTime - req.startTime) : 0;
    s.status = parseSpanStatus(req.status);
    s.kind = parseSpanKind(req.kind);
    s.attributes = cast(string[string]) req.attributes;
    s.resourceAttributes = cast(string[string]) req.resourceAttributes;

    foreach (ref ev; req.events) {
      SpanEvent se;
      se.name = ev.name;
      se.timestamp = ev.timestamp;
      se.attributes = cast(string[string]) ev.attributes;
      s.events ~= se;
    }

    if (req.traceId.length == 0)
      return CommandResult(false, "", "Trace ID is required");
    if (req.operationName.length == 0)
      return CommandResult(false, "", "Operation name is required");

    spanRepo.save(s);
    return CommandResult(true, s.id, "");
  }

  CommandResult ingestSpanBatch(IngestSpanBatchRequest req) {
    int count = 0;
    foreach (ref spanReq; req.spans) {
      if (spanReq.tenantId.length == 0)
        spanReq.tenantId = req.tenantId;
      auto result = ingestSpan(spanReq);
      if (result.success)
        count++;
    }
    return CommandResult(true, "", format("Ingested %d spans", count));
  }

  Span[] getTrace(TenantId tenantId, TraceId traceId) {
    return spanRepo.findByTraceId(tenantId, traceId);
  }

  Span[] getServiceSpans(TenantId tenantId, string serviceName) {
    return spanRepo.findByService(tenantId, serviceName);
  }

  Span[] getSpansInRange(TenantId tenantId, long startTime, long endTime) {
    return spanRepo.findByTimeRange(tenantId, startTime, endTime);
  }

  private static SpanStatus parseSpanStatus(string s) {
    switch (s) {
    case "ok":
      return SpanStatus.ok;
    case "error":
      return SpanStatus.error;
    case "timeout":
      return SpanStatus.timeout;
    default:
      return SpanStatus.unset;
    }
  }

  private static SpanKind parseSpanKind(string s) {
    switch (s) {
    case "client":
      return SpanKind.client;
    case "server":
      return SpanKind.server;
    case "producer":
      return SpanKind.producer;
    case "consumer":
      return SpanKind.consumer;
    default:
      return SpanKind.internal;
    }
  }
}
