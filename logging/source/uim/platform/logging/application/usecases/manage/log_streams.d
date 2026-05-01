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

// import std.conv : to;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManageLogStreamsUseCase { // TODO: UIMUseCase {
  private LogStreamRepository repo;

  this(LogStreamRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateLogStreamRequest req) {
    import std.uuid : randomUUID;

    if (req.name.length == 0)
      return CommandResult(false, "", "Stream name is required");

    LogStream stream;
    stream.id = randomUUID();
    stream.tenantId = req.tenantId;
    stream.name = req.name;
    stream.description = req.description;
    stream.sourceType = toLogSourceType(req.sourceType);
    stream.retentionPolicyId = req.retentionPolicyId;
    stream.isActive = true;
    stream.createdBy = req.createdBy;
    stream.createdAt = clockSeconds();

    repo.save(stream);
    return CommandResult(true, stream.id.value, "");
  }

  CommandResult update(string id, UpdateLogStreamRequest req) {
    return update(LogStreamId(id), req);
  }

  CommandResult update(LogStreamId id, UpdateLogStreamRequest req) {
    auto stream = repo.findById(id);
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

  bool hasById(string id) {
    return hasById(LogStreamId(id));
  }

  bool hasById(LogStreamId id) {
    return repo.existsById(id);
  }

  LogStream getById(string id) {
    return getById(LogStreamId(id));
  }

  LogStream getById(LogStreamId id) {
    return repo.findById(id);
  }

  LogStream[] list(string tenantId) {
    return list(TenantId(tenantId));
  }

  LogStream[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(string id) {
    return remove(LogStreamId(id));
  }

  CommandResult remove(LogStreamId id) {
    repo.remove(id);
    return CommandResult(true, id.value, "");
  }


}
