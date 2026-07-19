/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.search_logs;
// import uim.platform.logging.domain.entities.log_entry;
// import uim.platform.logging.domain.ports.repositories.log_entrys;
// import uim.platform.logging.domain.services.log_parser;


import uim.platform.logging;
mixin(ShowModule!());

@safe:
class SearchLogsUseCase { // TODO: UIMUseCase {
  private LogEntryRepository logRepo;

  this(LogEntryRepository logRepo) {
    this.logRepo = logRepo;
  }

  LogEntry[] searchLogs(SearchLogsRequest req) {
    // Route to the most specific query available
    if (!req.traceId.isEmpty)
      return logRepo.findByTrace(req.tenantId, req.traceId);

    if (!req.correlationId.isEmpty)
      return logRepo.findByCorrelation(req.tenantId, req.correlationId);

    if (!req.streamId.isEmpty)
      return logRepo.findByStream(req.tenantId, req.streamId);

    if (!req.level.isEmpty) {
      auto level = req.level.toLoggingLevel();
      return logRepo.findByLevel(req.tenantId, level);
    } 

    if (req.startTime > 0 && req.endTime > 0)
      return logRepo.findByTimeRange(req.tenantId, req.startTime, req.endTime);

    if (!req.query.isEmpty)
      return logRepo.search(req.tenantId, req.query);

    return logRepo.findByTenant(req.tenantId);
  }

  LogEntry getLog(TenantId tenantId, LogEntryId id) {
    return logRepo.findById(tenantId, id);
  }

  size_t count(TenantId tenantId) {
    return logRepo.countByTenant(tenantId);
  }
}

unittest {
  auto logRepo = new MemoryLogEntryRepository();
  auto usecase = new SearchLogsUseCase(logRepo);
  auto tenantId = TenantId("test-tenant");

  // Seed data
  LogEntry entry;
  entry.tenantId = tenantId;
  entry.level = LoggingLevel.warning;
  entry.message = "Something went wrong";
  entry.traceId = "trace-1";
  logRepo.save(entry);

  // Test search by traceId
  SearchLogsRequest req;
  req.tenantId = tenantId;
  req.traceId = TraceId("trace-1");
  auto results = usecase.searchLogs(req);
  assert(results.length == 1);
  assert(results[0].traceId.value == "trace-1");

  // Test search by level
  req.traceId = TraceId.init;
  req.level = "warning";
  results = usecase.searchLogs(req);
  assert(results.length == 1);
}
