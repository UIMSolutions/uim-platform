/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.transport_requests;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
/// Application service for transport request management (CTS-like).
class ManageTransportRequestsUseCase {
  protected ITransportRequestRepository repo;

  this(ITransportRequestRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createTransportRequest(CreateTransportRequestRequest req) {
    if (req.description.length == 0)
      return UsecaseResult(false, "", "Transport request description is required");

    if (req.owner.length == 0)
      return UsecaseResult(false, "", "Owner is required");
    
    if (req.sourceSystemId.isEmpty)
      return UsecaseResult(false, "", "Source system ID is required");

    auto tr = TransportRequest(req.tenantId);
    tr.sourceSystemId = req.sourceSystemId;
    tr.targetSystemId = req.targetSystemId;
    tr.description = req.description;
    tr.owner = req.owner;
    tr.transportType = req.transportType.to!TransportType;
    tr.status = TransportStatus.modifiable;

    repo.save(tr);
    return UsecaseResult(true, tr.id.value, "");
  }

  UsecaseResult addTransportTask(AddTransportTaskRequest req) {
    auto tr = repo.findById(req.tenantId, req.requestId);
    if (tr.isNull)
      return UsecaseResult(false, "", "Transport request not found");

    if (tr.status != TransportStatus.modifiable)
      return UsecaseResult(false, "", "Transport request is not modifiable");

    auto task = TransportTask(req.tenantId);
    task.owner = req.owner;
    task.status = TransportStatus.modifiable;
    task.description = req.description;
    task.objectList = req.objectList;
    tr.tasks ~= task;
    
    repo.update(tr);
    return UsecaseResult(true, task.id.value, "");
  }

  UsecaseResult releaseTransportTask(TenantId tenantId, TransportRequestId requestId, TransportTaskId taskId) {
    auto transportRequest = repo.findById(tenantId, requestId);
    if (transportRequest.isNull)
      return UsecaseResult(false, "", "Transport request not found");

    foreach (task; transportRequest.tasks) {
      if (task.id == taskId) {
        auto validation = TransportReleaseValidator.validateTaskRelease(task);
        if (!validation.valid) {
          string msg;
          foreach (i, e; validation.errors) {
            msg ~= i > 0
              ? "; " : e;
          }
          return UsecaseResult(false, "", msg);
        }
        task.status = TransportStatus.released;

      
        task.releasedAt = currentTimestamp();

        repo.update(transportRequest);
        return UsecaseResult(true, task.id.value, "");
      }
    }
    return UsecaseResult(false, "", "Task not found");
  }

  UsecaseResult releaseTransportRequest(TenantId tenantId, TransportRequestId id) {
    auto tr = repo.findById(tenantId, id);
    if (tr.isNull)
      return UsecaseResult(false, "", "Transport request not found");

    auto validation = TransportReleaseValidator.validateRelease(tr);
    if (!validation.valid) {
      string msg;
      foreach (i, e; validation.errors) {
        msg ~= i > 0
          ? "; " : e;
      }
      return UsecaseResult(false, "", msg);
    }

    tr.status = TransportStatus.released;

  
    tr.releasedAt = currentTimestamp();

    repo.update(tr);
    return UsecaseResult(true, id.value, "");
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

  UsecaseResult deleteTransportRequest(TenantId tenantId, TransportRequestId id) {
    auto request = repo.findById(tenantId, id);
    if (request.isNull)
      return UsecaseResult(false, "", "Transport request not found");

    if (request.status != TransportStatus.modifiable)
      return UsecaseResult(false, "", "Only modifiable transport requests can be deleted");

    repo.remove(request);
    return UsecaseResult(true, request.id.value, "");
  }
}

///
unittest {
//    auto repo = new TransportRequestRepository();
//    auto usecase = new ManageTransportRequestsUseCase(repo);
//    auto tenantId = TenantId("test-tenant");

}
