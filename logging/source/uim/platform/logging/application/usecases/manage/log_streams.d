/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.log_streams;

// import uim.platform.logging.domain.entities.log_stream;
// import uim.platform.logging.domain.ports.repositories.log_streams;
// import uim.platform.logging.domain.types;
// import uim.platform.logging.application.dto;


import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManageLogStreamsUseCase { // TODO: UIMUseCase {
  private LogStreamRepository repo;

  this(LogStreamRepository repo) {
    this.repo = repo;
  }

  CommandResult createStream(CreateLogStreamRequest req) {
    import std.uuid : randomUUID;

    if (req.name.length == 0)
      return CommandResult(false, "", "Stream name is required");

    LogStream stream;
    stream.initEntity(req.tenantId);
    stream.name = req.name;
    stream.description = req.description;
    stream.sourceType = req.sourceType.to!LogSourceType;
    stream.retentionPolicyId = req.retentionPolicyId;
    stream.isActive = true;
    stream.createdBy = req.createdBy;

    repo.save(stream);
    return CommandResult(true, stream.id.value, "");
  }

  CommandResult updateStream(TenantId tenantId, LogStreamId id, UpdateLogStreamRequest req) {
    auto stream = repo.findById(tenantId, id);
    if (stream.isNull)
      return CommandResult(false, "", "Log stream not found");

    if (req.description.length > 0)
      stream.description = req.description;
    if (req.retentionPolicyId.length > 0)
      stream.retentionPolicyId = req.retentionPolicyId;
    stream.isActive = req.isActive;
    stream.updatedAt = clockSeconds();

    repo.update(stream);
    return CommandResult(true, id.value, "");
  }

  bool hasStream(TenantId tenantId, LogStreamId id) {
    return repo.existsById(tenantId, id);
  }

  LogStream getStream(TenantId tenantId, LogStreamId id) {
    return repo.findById(tenantId, id);
  }

  LogStream[] listLogStreams(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult deleteLogStream(TenantId tenantId, LogStreamId id) {
    auto stream = repo.findById(tenantId, id);
    if (stream.isNull)
      return CommandResult(false, "", "Log stream not found");

    repo.remove(stream);
    return CommandResult(true, stream.id.value, "");
  }

}
