/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.application.usecases.manage.transport_requests;

import uim.platform.abap_enviroment.application.dto;
import uim.platform.abap_enviroment.domain.entities.transport_request;
import uim.platform.abap_enviroment.domain.ports.transport_request_repository;
import uim.platform.abap_enviroment.domain.services.transport_release_validator;
import uim.platform.abap_enviroment.domain.types;

// import std.conv : to;
// import std.uuid : randomUUID;

/// Application service for transport request management (CTS-like).
class ManageTransportRequestsUseCase
{
  private TransportRequestRepository repo;

  this(TransportRequestRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createRequest(CreateTransportRequestRequest req)
  {
    if (req.description.length == 0)
      return CommandResult("", "Transport request description is required");
    if (req.owner.length == 0)
      return CommandResult("", "Owner is required");
    if (req.sourceSystemId.length == 0)
      return CommandResult("", "Source system ID is required");

    auto id = randomUUID().toString();
    TransportRequest tr;
    tr.id = id;
    tr.tenantId = req.tenantId;
    tr.sourceSystemId = req.sourceSystemId;
    tr.targetSystemId = req.targetSystemId;
    tr.description = req.description;
    tr.owner = req.owner;
    tr.transportType = parseTransportType(req.transportType);
    tr.status = TransportStatus.modifiable;

    // import std.datetime.systime : Clock;
    tr.createdAt = Clock.currStdTime();

    repo.save(tr);
    return CommandResult(id, "");
  }

  CommandResult addTask(TransportRequestId requestId, AddTransportTaskRequest req)
  {
    auto tr = repo.findById(requestId);
    if (tr is null)
      return CommandResult("", "Transport request not found");

    if (tr.status != TransportStatus.modifiable)
      return CommandResult("", "Transport request is not modifiable");

    auto taskId = randomUUID().toString()[0 .. 8];
    TransportTask task;
    task.taskId = taskId;
    task.owner = req.owner;
    task.status = TransportStatus.modifiable;
    task.description = req.description;
    task.objectList = req.objectList;

    // import std.datetime.systime : Clock;
    task.createdAt = Clock.currStdTime();

    tr.tasks ~= task;
    repo.update(*tr);
    return CommandResult(taskId, "");
  }

  CommandResult releaseTask(TransportRequestId requestId, string taskId)
  {
    auto tr = repo.findById(requestId);
    if (tr is null)
      return CommandResult("", "Transport request not found");

    foreach (ref task; tr.tasks)
    {
      if (task.taskId == taskId)
      {
        auto validation = TransportReleaseValidator.validateTaskRelease(task);
        if (!validation.valid)
        {
          string msg;
          foreach (i, e; validation.errors)
          {
            if (i > 0)
              msg ~= "; ";
            msg ~= e;
          }
          return CommandResult("", msg);
        }
        task.status = TransportStatus.released;

        // import std.datetime.systime : Clock;
        task.releasedAt = Clock.currStdTime();

        repo.update(*tr);
        return CommandResult(taskId, "");
      }
    }
    return CommandResult("", "Task not found");
  }

  CommandResult releaseRequest(TransportRequestId id)
  {
    auto tr = repo.findById(id);
    if (tr is null)
      return CommandResult("", "Transport request not found");

    auto validation = TransportReleaseValidator.validateRelease(*tr);
    if (!validation.valid)
    {
      string msg;
      foreach (i, e; validation.errors)
      {
        if (i > 0)
          msg ~= "; ";
        msg ~= e;
      }
      return CommandResult("", msg);
    }

    tr.status = TransportStatus.released;

    // import std.datetime.systime : Clock;
    tr.releasedAt = Clock.currStdTime();

    repo.update(*tr);
    return CommandResult(id, "");
  }

  TransportRequest* getRequest(TransportRequestId id)
  {
    return repo.findById(id);
  }

  TransportRequest[] listRequests(SystemInstanceId systemId)
  {
    return repo.findBySystem(systemId);
  }

  TransportRequest[] listByStatus(SystemInstanceId systemId, string statusStr)
  {
    return repo.findByStatus(systemId, parseTransportStatus(statusStr));
  }

  CommandResult deleteRequest(TransportRequestId id)
  {
    auto tr = repo.findById(id);
    if (tr is null)
      return CommandResult("", "Transport request not found");

    if (tr.status != TransportStatus.modifiable)
      return CommandResult("", "Only modifiable transport requests can be deleted");

    repo.remove(id);
    return CommandResult(id, "");
  }
}

private TransportType parseTransportType(string s)
{
  switch (s)
  {
  case "workbench":
    return TransportType.workbench;
  case "customizing":
    return TransportType.customizing;
  case "transportOfCopies":
    return TransportType.transportOfCopies;
  default:
    return TransportType.workbench;
  }
}

private TransportStatus parseTransportStatus(string s)
{
  switch (s)
  {
  case "modifiable":
    return TransportStatus.modifiable;
  case "released":
    return TransportStatus.released;
  case "imported":
    return TransportStatus.imported;
  case "error":
    return TransportStatus.error;
  default:
    return TransportStatus.modifiable;
  }
}
