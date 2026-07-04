/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.ingest_traces;
// import uim.platform.logging.domain.entities.span;
// import uim.platform.logging.domain.ports.repositories.spans;


// import std.format : format;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class IngestTracesUseCase { // TODO: UIMUseCase {
  private SpanRepository spanRepo;

  this(SpanRepository spanRepo) {
    this.spanRepo = spanRepo;
  }

  CommandResult ingestSpan(IngestSpanRequest req) {
    import std.uuid : randomUUID;

    auto s = Span(req.tenantId);
    s.traceId = req.traceId;
    s.parentSpanId = req.parentSpanId;
    s.operationName = req.operationName;
    s.serviceName = req.serviceName;
    s.startTime = req.startTime;
    s.endTime = req.endTime;
    s.durationMs = (req.endTime > req.startTime) ? (req.endTime - req.startTime) : 0;
    s.status = req.status.to!SpanStatus;
    s.kind = req.kind.to!SpanKind;
    s.attributes = cast(string[string]) req.attributes;
    s.resourceAttributes = cast(string[string]) req.resourceAttributes;

    foreach (ev; req.events) {
      SpanEvent se;
      se.name = ev.name;
      se.timestamp = ev.timestamp;
      se.attributes = cast(string[string]) ev.attributes;
      s.events ~= se;
    }

    if (req.traceId.isEmpty)
      return CommandResult(false, "", "Trace ID is required");
    if (req.operationName.length == 0)
      return CommandResult(false, "", "Operation name is required");

    spanRepo.save(s);
    return CommandResult(true, s.id.value, "");
  }

  CommandResult ingestSpanBatch(IngestSpanBatchRequest req) {
    int count = 0;
    foreach (spanReq; req.spans) {
      if (spanReq.tenantId.isEmpty)
        spanReq.tenantId = req.tenantId;
      auto result = ingestSpan(spanReq);
      if (result.success)
        count++;
    }
    return CommandResult(true, "", format("Ingested %d spans", count));
  }

  Span[] getTrace(TenantId tenantId, TraceId traceId) {
    return spanRepo.findByTrace(tenantId, traceId);
  }

  Span[] getServiceSpans(TenantId tenantId, string serviceName) {
    return spanRepo.findByService(tenantId, serviceName);
  }

  Span[] getSpansInRange(TenantId tenantId, long startTime, long endTime) {
    return spanRepo.findByTimeRange(tenantId, startTime, endTime);
  }

}

unittest {
  auto repo = new MemorySpanRepository();
  auto usecase = new IngestTracesUseCase(repo);
  auto tenantId = TenantId("test-tenant");

  IngestSpanRequest req;
  req.tenantId = tenantId;
  req.traceId = "trace-123";
  req.operationName = "test-op";
  req.serviceName = "test-service";
  req.startTime = 1700000000;
  req.endTime = 1700000100;
  req.status = "ok";
  req.kind = "server";

  auto result = usecase.ingestSpan(req);
  assert(result.success);
  assert(!result.id.isEmpty);
  
  auto trace = usecase.getTrace(tenantId, TraceId("trace-123"));
  assert(trace.length == 1);
  assert(trace[0].operationName == "test-op");
}
