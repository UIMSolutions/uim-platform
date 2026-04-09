/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.search_logs;

// import uim.platform.logging.domain.entities.log_entry;
// import uim.platform.logging.domain.ports.repositories.log_entrys;
// import uim.platform.logging.domain.services.log_parser;
// import uim.platform.logging.domain.types;
// import uim.platform.logging.application.dto;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class SearchLogsUseCase : UIMUseCase {
  private LogEntryRepository logRepo;

  this(LogEntryRepository logRepo) {
    this.logRepo = logRepo;
  }

  LogEntry[] search(SearchLogsRequest req) {
    // Route to the most specific query available
    if (req.traceId.length > 0)
      return logRepo.findByTraceId(req.tenantId, req.traceId);

    if (req.correlationId.length > 0)
      return logRepo.findByCorrelation(req.tenantId, req.correlationId);

    if (req.streamId.length > 0)
      return logRepo.findByStream(req.tenantId, req.streamId);

    if (req.level.length > 0) {
      auto level = LogParser.parseLevel(req.level);
      return logRepo.findByLevel(req.tenantId, level);
    }

    if (req.startTime > 0 && req.endTime > 0)
      return logRepo.findByTimeRange(req.tenantId, req.startTime, req.endTime);

    if (req.query.length > 0)
      return logRepo.search(req.tenantId, req.query);

    return logRepo.findByTenant(req.tenantId);
  }

  LogEntry getById(LogEntryId id) {
    return logRepo.findById(id);
  }

  size_t count(TenantId tenantId) {
    return logRepo.countByTenant(tenantId);
  }
}
