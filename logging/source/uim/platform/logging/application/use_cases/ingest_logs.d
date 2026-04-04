/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.ingest_logs;

import uim.platform.logging.domain.entities.log_entry;
import uim.platform.logging.domain.ports.log_entry_repository;
import uim.platform.logging.domain.ports.log_stream_repository;
import uim.platform.logging.domain.services.log_parser;
import uim.platform.logging.domain.types;
import uim.platform.logging.application.dto;

import std.conv : to;
import std.format : format;

class IngestLogsUseCase : UIMUseCase {
  private LogEntryRepository logRepo;
  private LogStreamRepository streamRepo;

  this(LogEntryRepository logRepo, LogStreamRepository streamRepo) {
    this.logRepo = logRepo;
    this.streamRepo = streamRepo;
  }

  CommandResult ingest(IngestLogRequest req) {
    import std.uuid : randomUUID;

    LogEntry entry;
    entry.id = randomUUID().to!string;
    entry.tenantId = req.tenantId;
    entry.streamId = req.streamId;
    entry.timestamp = clockSeconds();
    entry.level = LogParser.parseLevel(req.level);
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
    return CommandResult(true, entry.id, "");
  }

  CommandResult ingestBatch(IngestLogBatchRequest req) {
    int count = 0;
    foreach (ref entryReq; req.entries) {
      if (entryReq.tenantId.length == 0)
        entryReq.tenantId = req.tenantId;
      auto result = ingest(entryReq);
      if (result.success)
        count++;
    }
    return CommandResult(true, "", format("Ingested %d log entries", count));
  }

  private static long clockSeconds() {
    import core.time : MonoTime;

    return MonoTime.currTime.ticks / MonoTime.ticksPerSecond;
  }
}
