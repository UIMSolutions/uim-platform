module uim.platform.data.quality.presentation.http.cleansing_job;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.data.quality.application.usecases.manage_cleansing_jobs;
import uim.platform.data.quality.application.dto;
import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.cleansing_job;
import uim.platform.data.quality.presentation.http.json_utils;

class CleansingJobController
{
  private ManageCleansingJobsUseCase uc;

  this(ManageCleansingJobsUseCase uc)
  {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/cleansing-jobs", &handleCreate);
    router.get("/api/v1/cleansing-jobs", &handleList);
    router.get("/api/v1/cleansing-jobs/*", &handleGetById);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateCleansingJobRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.datasetId = j.getString("datasetId");
      r.requestedBy = j.getString("requestedBy");
      r.ruleIds = jsonStrArray(j, "ruleIds");

      auto result = uc.create(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("pending");
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto jobs = uc.listByTenant(tenantId);
      auto arr = Json.emptyArray;
      foreach (ref j_; jobs)
        arr ~= serializeJob(j_);

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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto job = uc.getById(id, tenantId);
      if (job is null)
      {
        writeError(res, 404, "Cleansing job not found");
        return;
      }
      res.writeJsonBody(serializeJob(*job), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeJob(ref const CleansingJob j)
  {
    auto r = Json.emptyObject;
    r["id"] = Json(j.id);
    r["tenantId"] = Json(j.tenantId);
    r["datasetId"] = Json(j.datasetId);
    r["requestedBy"] = Json(j.requestedBy);
    r["status"] = Json(j.status.to!string);
    r["totalRecords"] = Json(j.totalRecords);
    r["processedRecords"] = Json(j.processedRecords);
    r["cleansedRecords"] = Json(j.cleansedRecords);
    r["errorRecords"] = Json(j.errorRecords);
    r["createdAt"] = Json(j.createdAt);
    r["startedAt"] = Json(j.startedAt);
    r["completedAt"] = Json(j.completedAt);

    if (j.errorMessage.length > 0)
      r["errorMessage"] = Json(j.errorMessage);

    if (j.ruleIds.length > 0)
    {
      auto ids = Json.emptyArray;
      foreach (id; j.ruleIds)
        ids ~= Json(id);
      r["ruleIds"] = ids;
    }

    return r;
  }
}
