/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.log_entries;

// import uim.platform.logging.domain.entities.log_entry;
// import uim.platform.logging.domain.ports.repositories.log_entrys;
// import uim.platform.logging.domain.types;

// import std.algorithm : filter;
// import std.array : array;
// import std.string : indexOf;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class MemoryLogEntryRepository : TenantRepository!(LogEntry, LogEntryId), LogEntryRepository {

  size_t countByStream(TenantId tenantId, LogStreamId streamId) {
    return findByStream(tenantId, streamId).length;
  }
  LogEntry[] filterByStream(LogEntry[] entries, LogStreamId streamId) {
    return entries.filter!(e => e.streamId == streamId).array;
  }
  LogEntry[] findByStream(TenantId tenantId, LogStreamId streamId) {
    return findByTenant(tenantId).filter!(e => e.streamId == streamId).array;
  }
  void removeByStream(TenantId tenantId, LogStreamId streamId) {
    findByStream(tenantId, streamId).each!(e => remove(e));
  }

  size_t countByLevel(TenantId tenantId, LoggingLevel level) {
    return findByLevel(tenantId, level).length;
  }
  LogEntry[] filterByLevel(LogEntry[] entries, LoggingLevel level) {
    return entries.filter!(e => e.level == level).array;
  }
  LogEntry[] findByLevel(TenantId tenantId, LoggingLevel level) {
    return filterByLevel(findByTenant(tenantId), level);
  }
  void removeByLevel(TenantId tenantId, LoggingLevel level) {
    findByLevel(tenantId, level).each!(e => remove(e));
  }

  size_t countByTimeRange(TenantId tenantId, long startTime, long endTime) {
    return findByTimeRange(tenantId, startTime, endTime).length;
  }
  LogEntry[] filterByTimeRange(LogEntry[] entries, long startTime, long endTime) {
    return entries.filter!(e => e.timestamp >= startTime && e.timestamp <= endTime).array;
  }
  LogEntry[] findByTimeRange(TenantId tenantId, long startTime, long endTime) {
    return filterByTimeRange(findByTenant(tenantId), startTime, endTime);
  }
  void removeByTimeRange(TenantId tenantId, long startTime, long endTime) {
    findByTimeRange(tenantId, startTime, endTime).each!(e => remove(e));
  }

  size_t countByTraceId(TenantId tenantId, TraceId traceId) {
    return findByTraceId(tenantId, traceId).length;
  }
  LogEntry[] filterByTraceId(LogEntry[] entries, TraceId traceId) {
    return entries.filter!(e => e.traceId == traceId).array;
  }
  LogEntry[] findByTraceId(TenantId tenantId, TraceId traceId) {
    return filterByTraceId(findByTenant(tenantId), traceId);
  }
  void removeByTraceId(TenantId tenantId, TraceId traceId) {
    findByTraceId(tenantId, traceId).each!(e => remove(e));
  }

  size_t countByCorrelationId(TenantId tenantId, string correlationId) {
    return findByCorrelation(tenantId, correlationId).length;
  }
  LogEntry[] filterByCorrelationId(LogEntry[] entries, string correlationId) {
    return entries.filter!(e => e.correlationId == correlationId).array;
  }
  LogEntry[] findByCorrelation(TenantId tenantId, string correlationId) {
    return filterByCorrelationId(findByTenant(tenantId), correlationId);
  }
  void removeByCorrelationId(TenantId tenantId, string correlationId) {
    findByCorrelation(tenantId, correlationId).each!(e => remove(e));
  }

  LogEntry[] search(TenantId tenantId, string query) {
    return findByTenant(tenantId).filter!(e => e.message.indexOf(query) >= 0).array;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    store = findByTenant(tenantId).filter!(e => e.timestamp >= beforeTimestamp).array;
  }

}
