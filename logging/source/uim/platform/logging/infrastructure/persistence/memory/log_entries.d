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
  private LogEntry[] store;

  bool existsById(LogEntryId id) {
    return store.any!(e => e.id == id);
  }

  LogEntry findById(LogEntryId id) {
    foreach(entry; findAll) {
      if (entry.id == id) {
        return entry;
      }
    }
    return LogEntry.init;
  }

  LogEntry[] findByTenant(TenantId tenantId) {
    return findAll().filter!(e => e.tenantId == tenantId).array;
  }

  LogEntry[] findByStream(TenantId tenantId, LogStreamId streamId) {
    return findByTenant(tenantId).filter!(e => e.streamId == streamId).array;
  }

  LogEntry[] findByLevel(TenantId tenantId, LoggingLevel level) {
    return findByTenant(tenantId).filter!(e => e.level == level).array;
  }

  LogEntry[] findByTimeRange(TenantId tenantId, long startTime, long endTime) {
    return findByTenant(tenantId).filter!(e => e.timestamp >= startTime && e.timestamp <= endTime).array;
  }

  LogEntry[] search(TenantId tenantId, string query) {
    return findByTenant(tenantId).filter!(e => e.message.indexOf(query) >= 0).array;
  }

  LogEntry[] findByTraceId(TenantId tenantId, TraceId traceId) {
    return findByTenant(tenantId).filter!(e => e.traceId == traceId).array;
  }

  LogEntry[] findByCorrelation(TenantId tenantId, string correlationId) {
    return findByTenant(tenantId).filter!(e => e.correlationId == correlationId).array;
  }

  void save(LogEntry entry) {
    store ~= entry;
  }

  void saveAll(LogEntry[] entries) {
    store ~= entries;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    store = findByTenant(tenantId).filter!(e => e.timestamp >= beforeTimestamp).array;
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }
}
