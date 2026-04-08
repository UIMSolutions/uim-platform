/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.deployment;

import uim.platform.ai_launchpad.application.usecases.manage.deployments;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

class DeploymentController : SAPController {
  private ManageDeploymentsUseCase uc;

  this(ManageDeploymentsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/deployments", &handleCreate);
    router.get("/api/v1/deployments", &handleList);
    router.get("/api/v1/deployments/*", &handleGet);
    router.patch("/api/v1/deployments/bulk", &handleBulkPatch);
    router.patch("/api/v1/deployments/*", &handlePatch);
    router.delete_("/api/v1/deployments/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto connectionId = req.headers.get("X-Connection-Id", "");

      CreateDeploymentRequest r;
      r.connectionId = connectionId;
      r.configurationId = j.getString("configurationId");
      r.resourceGroupId = j.getString("resourceGroupId");
      r.ttl = jsonInt(j, "ttl");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Deployment created");
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto connectionId = req.headers.get("X-Connection-Id", "");
      auto scenarioId = req.headers.get("X-Scenario-Id", "");

      typeof(uc.listByConnection(connectionId)) deployments;
      if (scenarioId.length > 0)
        deployments = uc.listByScenario(scenarioId, connectionId);
      else
        deployments = uc.listByConnection(connectionId);

      auto jarr = Json.emptyArray;
      foreach (ref d; deployments) {
        jarr ~= serializeDeployment(d);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) deployments.length);
      resp["resources"] = jarr;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto connectionId = req.headers.get("X-Connection-Id", "");

      auto d = uc.get_(id, connectionId);
      if (d.id.isEmpty) {
        writeError(res, 404, "Deployment not found");
        return;
      }

      res.writeJsonBody(serializeDeployment(d), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      auto connectionId = req.headers.get("X-Connection-Id", "");

      PatchDeploymentRequest r;
      r.connectionId = connectionId;
      r.deploymentId = id;
      r.targetStatus = j.getString("targetStatus");
      r.configurationId = j.getString("configurationId");
      r.ttl = jsonInt(j, "ttl");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["message"] = Json("Deployment updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleBulkPatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto connectionId = req.headers.get("X-Connection-Id", "");

      BulkPatchDeploymentRequest r;
      r.connectionId = connectionId;
      r.deploymentIds = jsonStrArray(j, "deploymentIds");
      r.targetStatus = j.getString("targetStatus");

      auto results = uc.bulkPatch(r);
      auto jarr = Json.emptyArray;
      foreach (ref result; results) {
        auto rj = Json.emptyObject;
        rj["id"] = Json(result.id);
        rj["success"] = Json(result.success);
        if (result.error.length > 0) rj["error"] = Json(result.error);
        jarr ~= rj;
      }

      auto resp = Json.emptyObject;
      resp["results"] = jarr;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto connectionId = req.headers.get("X-Connection-Id", "");

      auto result = uc.remove(id, connectionId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeDeployment(Deployment d) {
    import std.conv : to;
    import uim.platform.ai_launchpad.domain.entities.deployment : ScalingConfig;
    auto j = Json.emptyObject;
    j["id"] = Json(d.id);
    j["connectionId"] = Json(d.connectionId);
    j["configurationId"] = Json(d.configurationId);
    j["scenarioId"] = Json(d.scenarioId);
    j["resourceGroupId"] = Json(d.resourceGroupId);
    j["status"] = Json(d.status.to!string);
    j["targetStatus"] = Json(d.targetStatus);
    j["deploymentUrl"] = Json(d.deploymentUrl);

    auto sj = Json.emptyObject;
    sj["minReplicas"] = Json(cast(long) d.scaling.minReplicas);
    sj["maxReplicas"] = Json(cast(long) d.scaling.maxReplicas);
    j["scaling"] = sj;

    j["ttl"] = Json(cast(long) d.ttl);
    j["startedAt"] = Json(d.startedAt);
    j["stoppedAt"] = Json(d.stoppedAt);
    j["statusMessage"] = Json(d.statusMessage);
    j["createdAt"] = Json(d.createdAt);
    j["modifiedAt"] = Json(d.modifiedAt);
    return j;
  }
}
