/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.presentation.http.controllers.monitoring_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.identity.provisioning.application.usecases.monitor_provisioning;
import uim.platform.identity.provisioning.domain.entities.provisioning_log;
import uim.platform.identity.provisioning.domain.entities.provisioned_entity;
import uim.platform.identity.provisioning.domain.types;

class MonitoringController : PlatformController {
  private MonitorProvisioningUseCase uc;

  this(MonitorProvisioningUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/monitoring/jobs", &handleListJobSummaries);
    router.get("/api/v1/monitoring/jobs/*", &handleGetJobSummary);
    router.get("/api/v1/monitoring/logs/*", &handleGetJobLogs);
    router.get("/api/v1/monitoring/entities", &handleListEntities);
    router.get("/api/v1/monitoring/pipeline", &handlePipeline);
  }

  private void handleListJobSummaries(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listJobSummaries(tenantId);

      auto arr = items.map!(s => serializeJobSummary(s)).array;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetJobSummary(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto summary = uc.getJobSummary(tenantId, id);
      if (summary.jobId.isEmpty) {
        writeError(res, 404, "Job not found");
        return;
      }
      res.writeJsonBody(serializeJobSummary(summary), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetJobLogs(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto jobId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto logs = uc.getJobLogs(jobtenantId, id);

      auto arr = Json.emptyArray;
      foreach (l; logs)
        arr ~= serializeLog(l);

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", logs.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListEntities(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listProvisionedEntities(tenantId);

      auto arr = Json.emptyArray;
      foreach (e; items)
        arr ~= serializeEntity(e);

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(items.length));
      
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePipeline(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto summary = uc.getPipelineSummary(tenantId);

      auto j = Json.emptyObject
        .set("totalSourceSystems", summary.totalSourceSystems)
        .set("activeSourceSystems", summary.activeSourceSystems)
        .set("totalTargetSystems", summary.totalTargetSystems)
        .set("activeTargetSystems", summary.activeTargetSystems)
        .set("totalJobs", summary.totalJobs)
        .set("completedJobs", summary.completedJobs)
        .set("failedJobs", summary.failedJobs)
        .set("runningJobs", summary.runningJobs)
        .set("totalProvisionedEntities", summary.totalProvisionedEntities);

      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeJobSummary(const JobSummary s) {
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

  private static Json serializeLog(const ProvisioningLog l) {
    return Json.emptyObject
      .set("id", l.id)
      .set("jobId", l.jobId)
      .set("entityType", l.entityType.to!string)
      .set("entityId", l.entityId)
      .set("operation", l.operation.to!string)
      .set("status", l.status.to!string)
      .set("sourceSystem", l.sourceSystem)
      .set("targetSystem", l.targetSystem)
      .set("details", l.details)
      .set("createdAt", l.createdAt);
  }

  private static Json serializeEntity(const ProvisionedEntity e) {
    return Json.emptyObject
      .set("id", e.id)
      .set("externalId", e.externalId)
      .set("entityType", e.entityType.to!string)
      .set("sourceSystemId", e.sourceSystemId)
      .set("targetSystemId", e.targetSystemId)
      .set("attributes", e.attributes)
      .set("status", e.status.to!string)
      .set("lastSyncAt", e.lastSyncAt)
      .set("createdAt", e.createdAt)
      .set("updatedAt", e.updatedAt);
  }
}
