/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.use_cases.manage_log_streams;

import uim.platform.logging.domain.entities.log_stream;
import uim.platform.logging.domain.ports.log_stream_repository;
import uim.platform.logging.domain.types;
import uim.platform.logging.application.dto;

import std.conv : to;

class ManageLogStreamsUseCase : UIMUseCase {
  private LogStreamRepository repo;

  this(LogStreamRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateLogStreamRequest req) {
    import std.uuid : randomUUID;

    if (req.name.length == 0)
      return CommandResult(false, "", "Stream name is required");

    LogStream stream;
    stream.id = randomUUID().to!string;
    stream.tenantId = req.tenantId;
    stream.name = req.name;
    stream.description = req.description;
    stream.sourceType = parseSourceType(req.sourceType);
    stream.retentionPolicyId = req.retentionPolicyId;
    stream.isActive = true;
    stream.createdBy = req.createdBy;
    stream.createdAt = clockSeconds();

    repo.save(stream);
    return CommandResult(true, stream.id, "");
  }

  CommandResult update(LogStreamId id, UpdateLogStreamRequest req) {
    auto stream = repo.findById(id);
    if (stream.id.length == 0)
      return CommandResult(false, "", "Log stream not found");

    if (req.description.length > 0)
      stream.description = req.description;
    if (req.retentionPolicyId.length > 0)
      stream.retentionPolicyId = req.retentionPolicyId;
    stream.isActive = req.isActive;
    stream.updatedAt = clockSeconds();

    repo.update(stream);
    return CommandResult(true, id, "");
  }

  LogStream get_(LogStreamId id) {
    return repo.findById(id);
  }

  LogStream[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(LogStreamId id) {
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private static LogSourceType parseSourceType(string s) {
    switch (s) {
    case "application":
      return LogSourceType.application;
    case "request":
      return LogSourceType.request;
    case "system":
      return LogSourceType.system;
    case "cloudFoundry":
      return LogSourceType.cloudFoundry;
    case "kyma":
      return LogSourceType.kyma;
    case "kubernetes":
      return LogSourceType.kubernetes;
    default:
      return LogSourceType.custom;
    }
  }

  private static long clockSeconds() {
    import core.time : MonoTime;

    return MonoTime.currTime.ticks / MonoTime.ticksPerSecond;
  }
}
