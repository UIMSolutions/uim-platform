/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.log_entry_repository;

import uim.platform.logging.domain.entities.log_entry;
import uim.platform.logging.domain.types;

interface LogEntryRepository {
  LogEntry findById(LogEntryId id);
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
  long countByTenant(TenantId tenantId);
}
