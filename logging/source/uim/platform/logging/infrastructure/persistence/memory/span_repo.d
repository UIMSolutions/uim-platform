/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.span;

import uim.platform.logging.domain.entities.span;
import uim.platform.logging.domain.ports.repositories.spans;
import uim.platform.logging.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemorySpanRepository : SpanRepository {
  private Span[] store;

  Span findById(SpanId id) {
    foreach (ref s; store)
      if (s.id == id)
        return s;
    return Span.init;
  }

  Span[] findByTraceId(TenantId tenantId, TraceId traceId) {
    return store.filter!(s => s.tenantId == tenantId && s.traceId == traceId).array;
  }

  Span[] findByService(TenantId tenantId, string serviceName) {
    return store.filter!(s => s.tenantId == tenantId && s.serviceName == serviceName).array;
  }

  Span[] findByTimeRange(TenantId tenantId, long startTime, long endTime) {
    return store.filter!(s => s.tenantId == tenantId && s.startTime >= startTime && s.startTime <= endTime).array;
  }

  Span[] findByOperation(TenantId tenantId, string serviceName, string operationName) {
    return store.filter!(
        s => s.tenantId == tenantId && s.serviceName == serviceName && s.operationName == operationName).array;
  }

  void save(Span s) {
    store ~= s;
  }

  void saveAll(Span[] spans) {
    store ~= spans;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    store = store.filter!(s => !(s.tenantId == tenantId && s.startTime < beforeTimestamp)).array;
  }

  size_t countByTenant(TenantId tenantId) {
    return cast(long) store.filter!(s => s.tenantId == tenantId).array.length;
  }
}
