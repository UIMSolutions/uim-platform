/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.transport_requests;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.transport_request;
// import uim.platform.abap_environment.domain.ports.repositories.transport_request;
// import uim.platform.abap_environment.domain.services.transport_release_validator;
// import uim.platform.abap_environment.domain.types;
// import std.uuid : randomUUID;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Application service for transport request management (CTS-like).
class ManageTransportRequestsUseCase { // TODO: UIMUseCase {
  private TransportRequestRepository repo;

  this(TransportRequestRepository repo) {
    this.repo = repo;
  }

  CommandResult createTransportRequest(CreateTransportRequestRequest req) {
    if (req.description.length == 0)
      return CommandResult(false, "", "Transport request description is required");
    if (req.owner.length == 0)
      return CommandResult(false, "", "Owner is required");
    if (req.sourceSystemId.isEmpty)
      return CommandResult(false, "", "Source system ID is required");

    TransportRequest tr;
    tr.initEntity(req.tenantId);
    tr.sourceSystemId = req.sourceSystemId;
    tr.targetSystemId = req.targetSystemId;
    tr.description = req.description;
    tr.owner = req.owner;
    tr.transportType = req.transportType.to!TransportType;
    tr.status = TransportStatus.modifiable;

    repo.save(tr);
    return CommandResult(true, tr.id.value, "");
  }

  CommandResult addTransportTask(AddTransportTaskRequest req) {
    auto tr = repo.findById(req.tenantId, req.transportRequestId);
    if (tr.isNull)
      return CommandResult(false, "", "Transport request not found");

    if (tr.status != TransportStatus.modifiable)
      return CommandResult(false, "", "Transport request is not modifiable");

    auto taskId = randomUUID().toString()[0 .. 8];
    TransportTask task;
    task.initEntity();
    task.id = taskId;
    task.owner = req.owner;
    task.status = TransportStatus.modifiable;
    task.description = req.description;
    task.objectList = req.objectList;

  
    task.createdAt = currentTimestamp();

    tr.tasks ~= task;
    repo.update(tr);
    return CommandResult(true, task.id.value, "");
  }

  CommandResult releaseTransportTask(TenantId tenantId, TransportRequestId requestId, TransportTaskId taskId) {
    auto transportRequest = repo.findById(tenantId, requestId);
    if (transportRequest.isNull)
      return CommandResult(false, "", "Transport request not found");

    foreach (task; transportRequest.tasks) {
      if (task.id == taskId) {
        auto validation = TransportReleaseValidator.validateTaskRelease(task);
        if (!validation.valid) {
          string msg;
          foreach (i, e; validation.errors) {
            msg ~= i > 0
              ? "; " : e;
          }
          return CommandResult(false, "", msg);
        }
        task.status = TransportStatus.released;

      
        task.releasedAt = currentTimestamp();

        repo.update(transportRequest);
        return CommandResult(true, task.id.value, "");
      }
    }
    return CommandResult(false, "", "Task not found");
  }

  CommandResult releaseTransportRequest(TenantId tenantId, TransportRequestId id) {
    auto tr = repo.findById(tenantId, id);
    if (tr.isNull)
      return CommandResult(false, "", "Transport request not found");

    auto validation = TransportReleaseValidator.validateRelease(tr);
    if (!validation.valid) {
      string msg;
      foreach (i, e; validation.errors) {
        msg ~= i > 0
          ? "; " : e;
      }
      return CommandResult(false, "", msg);
    }

    tr.status = TransportStatus.released;

  
    tr.releasedAt = currentTimestamp();

    repo.update(tr);
    return CommandResult(true, id.value, "");
  }

  TransportRequest getTransportRequest(TenantId tenantId, TransportRequestId id) {
    return repo.findById(tenantId, id);
  }

  TransportRequest[] listTransportRequests(TenantId tenantId, SystemInstanceId systemId) {
    return repo.findBySystem(tenantId, systemId);
  }

  TransportRequest[] listTransportRequests(TenantId tenantId, SystemInstanceId systemId, TransportStatus status) {
    return repo.findByStatus(tenantId, systemId, status);
  }

  CommandResult deleteTransportRequest(TenantId tenantId, TransportRequestId id) {
    auto request = repo.findById(tenantId, id);
    if (request.isNull)
      return CommandResult(false, "", "Transport request not found");

    if (request.status != TransportStatus.modifiable)
      return CommandResult(false, "", "Only modifiable transport requests can be deleted");

    repo.remove(request);
    return CommandResult(true, request.id.value, "");
  }
}

