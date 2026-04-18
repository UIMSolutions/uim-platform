/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.repositories.log_entries;

// import uim.platform.logging.domain.entities.log_entry;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface LogEntryRepository {
  bool existsById(LogEntryId id);
  LogEntry findById(LogEntryId id);

  size_t countByTenant(TenantId tenantId);
  LogEntry[] findByTenant(TenantId tenantId);
  
  LogEntry[] findByStream(TenantId tenantId, LogStreamId streamId);
  LogEntry[] findByLevel(TenantId tenantId, LogLevel level);
  LogEntry[] findByTimeRange(TenantId tenantId, long startTime, long endTime);
  LogEntry[] search(TenantId tenantId, string query);
  LogEntry[] findByTraceId(TenantId tenantId, TraceId traceId);
  LogEntry[] findByCorrelation(TenantId tenantId, string correlationId);

  void save(LogEntry entry);
  void saveAll(LogEntry[] entries);
  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
