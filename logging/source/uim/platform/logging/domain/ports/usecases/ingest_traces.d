/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.usecases.ingest_traces;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface IIngestTracesUseCase { 
  
  CommandResult ingestSpan(IngestSpanRequest req);

  CommandResult ingestSpanBatch(IngestSpanBatchRequest req) ;

  Span[] getTrace(TenantId tenantId, TraceId traceId);

  Span[] getServiceSpans(TenantId tenantId, string serviceName);

  Span[] getSpansInRange(TenantId tenantId, long startTime, long endTime);
  
}
