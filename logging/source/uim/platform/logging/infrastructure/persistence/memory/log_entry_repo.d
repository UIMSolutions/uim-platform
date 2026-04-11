/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.log_entry;

// import uim.platform.logging.domain.entities.log_entry;
// import uim.platform.logging.domain.ports.repositories.log_entrys;
// import uim.platform.logging.domain.types;

// import std.algorithm : filter;
// import std.array : array;
// import std.string : indexOf;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class MemoryLogEntryRepository : LogEntryRepository {
  private LogEntry[] store;

  LogEntry findById(LogEntryId id) {
    foreach (e; store)
      if (e.id == id)
        return e;
    return LogEntry.init;
  }

  LogEntry[] findByTenant(TenantId tenantId) {
    return store.filter!(e => e.tenantId == tenantId).array;
  }

  LogEntry[] findByStream(TenantId tenantId, LogStreamId streamId) {
    return store.filter!(e => e.tenantId == tenantId && e.streamId == streamId).array;
  }

  LogEntry[] findByLevel(TenantId tenantId, LogLevel level) {
    return store.filter!(e => e.tenantId == tenantId && e.level == level).array;
  }

  LogEntry[] findByTimeRange(TenantId tenantId, long startTime, long endTime) {
    return store.filter!(e => e.tenantId == tenantId && e.timestamp >= startTime && e.timestamp <= endTime).array;
  }

  LogEntry[] search(TenantId tenantId, string query) {
    return store.filter!(e => e.tenantId == tenantId && e.message.indexOf(query) >= 0).array;
  }

  LogEntry[] findByTraceId(TenantId tenantId, TraceId traceId) {
    return store.filter!(e => e.tenantId == tenantId && e.traceId == traceId).array;
  }

  LogEntry[] findByCorrelation(TenantId tenantId, string correlationId) {
    return store.filter!(e => e.tenantId == tenantId && e.correlationId == correlationId).array;
  }

  void save(LogEntry entry) {
    store ~= entry;
  }

  void saveAll(LogEntry[] entries) {
    store ~= entries;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    store = store.filter!(e => !(e.tenantId == tenantId && e.timestamp < beforeTimestamp)).array;
  }

  size_t countByTenant(TenantId tenantId) {
    return cast(long) store.filter!(e => e.tenantId == tenantId).array.length;
  }
}
