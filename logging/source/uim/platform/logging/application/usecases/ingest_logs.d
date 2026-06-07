/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.ingest_logs;
// import uim.platform.logging.domain.entities.log_entry;
// import uim.platform.logging.domain.ports.repositories.log_entrys;
// import uim.platform.logging.domain.ports.repositories.log_streams;
// import uim.platform.logging.domain.services.log_parser;


// import std.format : format;
import uim.platform.logging;

// mixin(ShowModule!());

@safe:
class IngestLogsUseCase { // TODO: UIMUseCase {
  private LogEntryRepository logRepo;
  private LogStreamRepository streamRepo;

  this(LogEntryRepository logRepo, LogStreamRepository streamRepo) {
    this.logRepo = logRepo;
    this.streamRepo = streamRepo;
  }

  CommandResult ingest(IngestLogRequest req) {
    import std.uuid : randomUUID;

    LogEntry entry;
    entry.initEntity(req.tenantId);

    entry.streamId = req.streamId;
    entry.timestamp = clockSeconds();
    entry.level = req.level.toLoggingLevel();
    entry.source = req.source;
    entry.message = req.message;
    entry.structuredData = cast(string[string]) req.structuredData;
    entry.traceId = req.traceId;
    entry.spanId = req.spanId;
    entry.requestId = req.requestId;
    entry.correlationId = req.correlationId;
    entry.componentName = req.componentName;
    entry.spaceName = req.spaceName;
    entry.orgName = req.orgName;
    entry.resourceType = req.resourceType;
    entry.resourceId = req.resourceId;
    entry.tags = cast(string[]) req.tags;

    auto validation = LogParser.validate(entry);
    if (!validation.valid) {
      string msg;
      foreach (e; validation.errors)
        msg ~= e ~ "; ";
      return CommandResult(false, "", msg);
    }

    logRepo.save(entry);
    return CommandResult(true, entry.id.value, "");
  }

  CommandResult ingestBatch(IngestLogBatchRequest req) {
    int count = 0;
    foreach (entryReq; req.entries) {
      if (entryReq.tenantId.isEmpty)
        entryReq.tenantId = req.tenantId;
      auto result = ingest(entryReq);
      if (result.success)
        count++;
    }
    return CommandResult(true, "", format("Ingested %d log entries", count));
  }
}

unittest {
  auto logRepo = new MemoryLogEntryRepository();
  auto streamRepo = new MemoryLogStreamRepository();
  auto usecase = new IngestLogsUseCase(logRepo, streamRepo);
  auto tenantId = TenantId("test-tenant");

  // Test single ingestion
  IngestLogRequest req;
  req.tenantId = tenantId;
  req.level = "info";
  req.message = "Application started";
  req.source = "main-app";

  auto result = usecase.ingest(req);
  assert(result.success);
  assert(!result.id.isEmpty);
  assert(logRepo.countByTenant(tenantId) == 1);

  // Test batch ingestion
  IngestLogBatchRequest batch;
  batch.tenantId = tenantId;
  // Reuse the request for batch entries
  batch.entries = [req, req];
  
  auto batchResult = usecase.ingestBatch(batch);
  assert(batchResult.success);
  assert(logRepo.countByTenant(tenantId) == 3); // 1 + 2
}
