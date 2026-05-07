/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.spans;

// import uim.platform.logging.domain.entities.span;
// import uim.platform.logging.domain.ports.repositories.spans;
// import uim.platform.logging.domain.types;
// 
// import std.algorithm : filter;
// import std.array : array;
import uim.platform.logging;

mixin(ShowModule!());

@safe:

class MemorySpanRepository : TenantRepository!(Span, SpanId), SpanRepository {

  Span[] findByTrace(TenantId tenantId, string traceId) {
    return findByTenant(tenantId).filter!(s => s.traceId == traceId).array;
  }

  Span[] findByService(TenantId tenantId, string serviceName) {
    return findByTenant(tenantId).filter!(s => s.serviceName == serviceName).array;
  }

  Span[] findByTimeRange(TenantId tenantId, long startTime, long endTime) {
    return findByTenant(tenantId).filter!(s => s.startTime >= startTime && s.startTime <= endTime).array;
  }

  Span[] findByOperation(TenantId tenantId, string serviceName, string operationName) {
    return findByTenant(tenantId).filter!(
        s => s.serviceName == serviceName && s.operationName == operationName).array;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    findByTenant(tenantId).filter!(s => s.startTime >= beforeTimestamp).each!(s => remove(s));
  }

}
