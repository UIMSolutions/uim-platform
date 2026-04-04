/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.http.controllers.application_job;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.abap_enviroment.application.usecases.manage.application_jobs;
// import uim.platform.abap_enviroment.application.dto;
// import uim.platform.abap_enviroment.domain.entities.application_job;
// import uim.platform.abap_enviroment.domain.types;
// import uim.platform.abap_enviroment.presentation.http.json_utils;

import uim.platform.abap_enviroment;

mixin(ShowModule!());
@safe:

class ApplicationJobController {
  private ManageApplicationJobsUseCase uc;

  this(ManageApplicationJobsUseCase uc)
  {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/application-jobs", &handleCreate);
    router.get("/api/v1/application-jobs", &handleList);
    router.get("/api/v1/application-jobs/*", &handleGetById);
    router.put("/api/v1/application-jobs/*", &handleUpdate);
    router.post("/api/v1/application-jobs/cancel/*", &handleCancel);
    router.delete_("/api/v1/application-jobs/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      CreateApplicationJobRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.systemInstanceId = j.getString("systemInstanceId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.jobTemplateName = j.getString("jobTemplateName");
      r.frequency = j.getString("frequency");
      r.scheduledAt = jsonLong(j, "scheduledAt");
      r.cronExpression = j.getString("cronExpression");

      auto result = uc.createJob(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto systemId = req.headers.get("X-System-Id", "");
      auto jobs = uc.listJobs(systemId);
      auto arr = Json.emptyArray;
      foreach (ref job; jobs)
        arr ~= serializeJob(job);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) jobs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto job = uc.getJob(id);
      if (job is null)
      {
        writeError(res, 404, "Application job not found");
        return;
      }
      res.writeJsonBody(serializeJob(*job), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateApplicationJobRequest r;
      r.description = j.getString("description");
      r.frequency = j.getString("frequency");
      r.scheduledAt = jsonLong(j, "scheduledAt");
      r.cronExpression = j.getString("cronExpression");
      r.active = j.getBoolean("active", true);

      auto result = uc.updateJob(id, r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.cancelJob(id);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("canceled");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteJob(id);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("deleted");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeJob(ref const ApplicationJob job)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(job.id);
    j["tenantId"] = Json(job.tenantId);
    j["systemInstanceId"] = Json(job.systemInstanceId);
    j["name"] = Json(job.name);
    j["description"] = Json(job.description);
    j["jobTemplateName"] = Json(job.jobTemplateName);
    j["frequency"] = Json(job.frequency.to!string);
    j["scheduledAt"] = Json(job.scheduledAt);
    j["cronExpression"] = Json(job.cronExpression);
    j["active"] = Json(job.active);
    j["status"] = Json(job.status.to!string);
    j["createdAt"] = Json(job.createdAt);
    j["updatedAt"] = Json(job.updatedAt);

    if (job.executionHistory.length > 0)
    {
      auto hist = Json.emptyArray;
      foreach (ref ex; job.executionHistory)
      {
        auto ej = Json.emptyObject;
        ej["executionId"] = Json(ex.executionId);
        ej["status"] = Json(ex.status.to!string);
        ej["startedAt"] = Json(ex.startedAt);
        ej["finishedAt"] = Json(ex.finishedAt);
        ej["message"] = Json(ex.message);
        ej["returnCode"] = Json(cast(long) ex.returnCode);
        hist ~= ej;
      }
      j["executionHistory"] = hist;
    }

    return j;
  }
}
