/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.log_streams;
// import uim.platform.logging.domain.entities.log_stream;
// import uim.platform.logging.domain.ports.repositories.log_streams;


import std.conv : ConvException, to;
import std.string : toLower;
import uim.platform.logging;

// mixin(ShowModule!());

@safe:
class ManageLogStreamsUseCase { // TODO: UIMUseCase {
  private LogStreamRepository repo;

  private bool tryParseSourceType(string raw, out LogSourceType sourceType) {
    auto normalized = raw.toLower;
    if (normalized == "app")
      normalized = "application";
    if (normalized == "cloudfoundry" || normalized == "cloud_foundry")
      normalized = "cloudFoundry";

    try {
      sourceType = normalized.to!LogSourceType;
      return true;
    } catch (ConvException) {
      return false;
    }
  }

  this(LogStreamRepository repo) {
    this.repo = repo;
  }

  CommandResult createStream(CreateLogStreamRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Stream name is required");

    LogSourceType sourceType;
    if (!tryParseSourceType(req.sourceType, sourceType))
      return CommandResult(false, "", "Invalid source type: " ~ req.sourceType);

    LogStream stream;
    stream.initEntity(req.tenantId);
    stream.name = req.name;
    stream.description = req.description;
    stream.sourceType = sourceType;
    stream.retentionPolicyId = req.retentionPolicyId;
    stream.isActive = true;
    stream.createdBy = req.createdBy;

    repo.save(stream);
    return CommandResult(true, stream.id.value, "");
  }

  CommandResult updateStream(UpdateLogStreamRequest req) {
    auto stream = repo.findById(req.tenantId, req.streamId);
    if (stream.isNull)
      return CommandResult(false, "", "Log stream not found");

    if (req.description.length > 0)
      stream.description = req.description;
    if (req.retentionPolicyId.length > 0)
      stream.retentionPolicyId = req.retentionPolicyId;
    stream.isActive = req.isActive;
    stream.updatedAt = clockSeconds();

    repo.update(stream);
    return CommandResult(true, stream.id.value, "");
  }

  bool hasStream(TenantId tenantId, LogStreamId id) {
    return repo.existsById(tenantId, id);
  }

  LogStream getStream(TenantId tenantId, LogStreamId id) {
    return repo.findById(tenantId, id);
  }

  LogStream[] listStreams(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult deleteStream(TenantId tenantId, LogStreamId id) {
    auto stream = repo.findById(tenantId, id);
    if (stream.isNull)
      return CommandResult(false, "", "Log stream not found");

    repo.remove(stream);
    return CommandResult(true, stream.id.value, "");
  }

}

unittest {
  auto repo = new MemoryLogStreamRepository();
  auto usecase = new ManageLogStreamsUseCase(repo);
  auto tenantId = TenantId("test-tenant");

  // Create a stream
  CreateLogStreamRequest createReq;
  createReq.tenantId = tenantId;
  createReq.name = "application-logs";
  createReq.sourceType = "app";
  
  auto createRes = usecase.createStream(createReq);
  assert(createRes.success);
  auto streamId = LogStreamId(createRes.id);
  assert(usecase.hasStream(tenantId, streamId));

  // Update the stream
  UpdateLogStreamRequest updateReq;
  updateReq.tenantId = tenantId;
  updateReq.streamId = streamId;
  updateReq.description = "New description";
  updateReq.isActive = true;

  auto updateRes = usecase.updateStream(updateReq);
  assert(updateRes.success);
  auto stream = usecase.getStream(tenantId, streamId);
  assert(stream.description == "New description");

  // Delete the stream
  usecase.deleteStream(tenantId, streamId);
  assert(!usecase.hasStream(tenantId, streamId));
}
