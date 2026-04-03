/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.span_repository;

import uim.platform.logging.domain.entities.span;
import uim.platform.logging.domain.types;

interface SpanRepository {
  Span findById(SpanId id);
  Span[] findByTraceId(TenantId tenantId, TraceId traceId);
  Span[] findByService(TenantId tenantId, string serviceName);
  Span[] findByTimeRange(TenantId tenantId, long startTime, long endTime);
  Span[] findByOperation(TenantId tenantId, string serviceName, string operationName);
  void save(Span s);
  void saveAll(Span[] spans);
  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
  long countByTenant(TenantId tenantId);
}
