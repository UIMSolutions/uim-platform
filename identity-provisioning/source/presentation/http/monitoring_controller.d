module presentation.http.monitoring;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.monitor_provisioning;
import domain.entities.provisioning_log;
import domain.entities.provisioned_entity;
import domain.types;
import presentation.http.json_utils;

class MonitoringController
{
  private MonitorProvisioningUseCase uc;

  this(MonitorProvisioningUseCase uc)
  {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router)
  {
    router.get("/api/v1/monitoring/jobs", &handleListJobSummaries);
    router.get("/api/v1/monitoring/jobs/*", &handleGetJobSummary);
    router.get("/api/v1/monitoring/logs/*", &handleGetJobLogs);
    router.get("/api/v1/monitoring/entities", &handleListEntities);
    router.get("/api/v1/monitoring/pipeline", &handlePipeline);
  }

  private void handleListJobSummaries(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listJobSummaries(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref s; items)
        arr ~= serializeJobSummary(s);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetJobSummary(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto summary = uc.getJobSummary(id, tenantId);
      if (summary.jobId.length == 0)
      {
        writeError(res, 404, "Job not found");
        return;
      }
      res.writeJsonBody(serializeJobSummary(summary), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetJobLogs(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto jobId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto logs = uc.getJobLogs(jobId, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref l; logs)
        arr ~= serializeLog(l);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) logs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListEntities(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listProvisionedEntities(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref e; items)
        arr ~= serializeEntity(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePipeline(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto summary = uc.getPipelineSummary(tenantId);

      auto j = Json.emptyObject;
      j["totalSourceSystems"] = Json(cast(long) summary.totalSourceSystems);
      j["activeSourceSystems"] = Json(cast(long) summary.activeSourceSystems);
      j["totalTargetSystems"] = Json(cast(long) summary.totalTargetSystems);
      j["activeTargetSystems"] = Json(cast(long) summary.activeTargetSystems);
      j["totalJobs"] = Json(cast(long) summary.totalJobs);
      j["completedJobs"] = Json(cast(long) summary.completedJobs);
      j["failedJobs"] = Json(cast(long) summary.failedJobs);
      j["runningJobs"] = Json(cast(long) summary.runningJobs);
      j["totalProvisionedEntities"] = Json(summary.totalProvisionedEntities);
      res.writeJsonBody(j, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeJobSummary(ref const JobSummary s)
  {
    auto j = Json.emptyObject;
    j["jobId"] = Json(s.jobId);
    j["sourceName"] = Json(s.sourceName);
    j["targetName"] = Json(s.targetName);
    j["jobType"] = Json(s.jobType.to!string);
    j["status"] = Json(s.status.to!string);
    j["totalEntities"] = Json(s.totalEntities);
    j["processedEntities"] = Json(s.processedEntities);
    j["failedEntities"] = Json(s.failedEntities);
    j["startedAt"] = Json(s.startedAt);
    j["completedAt"] = Json(s.completedAt);
    return j;
  }

  private static Json serializeLog(ref const ProvisioningLog l)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(l.id);
    j["jobId"] = Json(l.jobId);
    j["entityType"] = Json(l.entityType.to!string);
    j["entityId"] = Json(l.entityId);
    j["operation"] = Json(l.operation.to!string);
    j["status"] = Json(l.status.to!string);
    j["sourceSystem"] = Json(l.sourceSystem);
    j["targetSystem"] = Json(l.targetSystem);
    j["details"] = Json(l.details);
    j["createdAt"] = Json(l.createdAt);
    return j;
  }

  private static Json serializeEntity(ref const ProvisionedEntity e)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["externalId"] = Json(e.externalId);
    j["entityType"] = Json(e.entityType.to!string);
    j["sourceSystemId"] = Json(e.sourceSystemId);
    j["targetSystemId"] = Json(e.targetSystemId);
    j["attributes"] = Json(e.attributes);
    j["status"] = Json(e.status.to!string);
    j["lastSyncAt"] = Json(e.lastSyncAt);
    j["createdAt"] = Json(e.createdAt);
    j["updatedAt"] = Json(e.updatedAt);
    return j;
  }
}
