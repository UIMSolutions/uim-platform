/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.repositories.spans;
// import uim.platform.logging.domain.entities.span;

import uim.platform.logging;

// mixin(ShowModule!());

@safe:
interface SpanRepository : ITentRepository!(Span, SpanId) {

  Span[] findByTrace(TenantId tenantId, TraceId traceId);
  Span[] findByService(TenantId tenantId, string serviceName);
  Span[] findByTimeRange(TenantId tenantId, long startTime, long endTime);
  Span[] findByOperation(TenantId tenantId, string serviceName, string operationName);

  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
