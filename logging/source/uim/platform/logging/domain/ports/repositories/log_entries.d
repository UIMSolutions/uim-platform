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
interface LogEntryRepository : ITenantRepository!(LogEntry, LogEntryId) {

  size_t countByStream(TenantId tenantId, LogStreamId streamId);
  LogEntry[] findByStream(TenantId tenantId, LogStreamId streamId);
  void removeByStream(TenantId tenantId, LogStreamId streamId);

  size_t countByLevel(TenantId tenantId, LoggingLevel level);
  LogEntry[] findByLevel(TenantId tenantId, LoggingLevel level);
  void removeByLevel(TenantId tenantId, LoggingLevel level);

  size_t countByTimeRange(TenantId tenantId, long startTime, long endTime);
  LogEntry[] findByTimeRange(TenantId tenantId, long startTime, long endTime);
  void removeByTimeRange(TenantId tenantId, long startTime, long endTime);

  size_t countBySearch(TenantId tenantId, string query);
  LogEntry[] search(TenantId tenantId, string query);
  void removeBySearch(TenantId tenantId, string query);

  size_t countByTraceId(TenantId tenantId, TraceId traceId);
  LogEntry[] findByTraceId(TenantId tenantId, TraceId traceId);
  void removeByTraceId(TenantId tenantId, TraceId traceId);

  size_t countByCorrelation(TenantId tenantId, string correlationId);
  LogEntry[] findByCorrelation(TenantId tenantId, string correlationId);
  void removeByCorrelation(TenantId tenantId, string correlationId);

  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
