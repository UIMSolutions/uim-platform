/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.training_job;

import uim.platform.document_ai.application.usecases.manage.training_jobs;
import uim.platform.document_ai.application.dto;
import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.training_job : TrainingJob;
import uim.platform.document_ai.presentation.http.json_utils;

import uim.platform.document_ai;

class TrainingJobController : SAPController {
  private ManageTrainingJobsUseCase uc;

  this(ManageTrainingJobsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/training/jobs", &handleCreate);
    router.get("/api/v1/training/jobs", &handleList);
    router.get("/api/v1/training/jobs/*", &handleGet);
    router.patch_("/api/v1/training/jobs/*", &handlePatch);
    router.delete_("/api/v1/training/jobs/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateTrainingJobRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.clientId = req.headers.get("X-Client-Id", "");
      r.documentTypeId = jsonStr(j, "documentTypeId");
      r.schemaId = jsonStr(j, "schemaId");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Training job created");
        res.writeJsonBody(resp, 201);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto clientId = req.headers.get("X-Client-Id", "");
      auto jobs = uc.list(clientId);

      auto jarr = Json.emptyArray;
      foreach (ref tj; jobs) {
        jarr ~= jobToJson(tj);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) jobs.length);
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
      auto clientId = req.headers.get("X-Client-Id", "");

      auto tj = uc.get_(id, clientId);
      if (tj.id.length == 0) {
        writeError(res, 404, "Training job not found");
        return;
      }

      res.writeJsonBody(jobToJson(tj), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      PatchTrainingJobRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.clientId = req.headers.get("X-Client-Id", "");
      r.trainingJobId = id;
      r.targetStatus = jsonStr(j, "targetStatus");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Training job updated");
        res.writeJsonBody(resp, 200);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = req.headers.get("X-Client-Id", "");

      auto result = uc.remove(id, clientId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } ) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json jobToJson(ref TrainingJob tj) {
    import std.conv : to;

    auto jj = Json.emptyObject;
    jj["id"] = Json(tj.id);
    jj["documentTypeId"] = Json(tj.documentTypeId);
    jj["schemaId"] = Json(tj.schemaId);
    jj["name"] = Json(tj.name);
    jj["description"] = Json(tj.description);
    jj["modelVersion"] = Json(tj.modelVersion);
    jj["status"] = Json(tj.status.to!string);
    jj["statusMessage"] = Json(tj.statusMessage);
    jj["documentCount"] = Json(cast(long) tj.documentCount);
    jj["accuracy"] = Json(tj.accuracy);
    jj["startedAt"] = Json(tj.startedAt);
    jj["completedAt"] = Json(tj.completedAt);
    jj["createdAt"] = Json(tj.createdAt);
    jj["modifiedAt"] = Json(tj.modifiedAt);

    auto mArr = Json.emptyArray;
    foreach (ref m; tj.metrics) {
      auto mj = Json.emptyObject;
      mj["name"] = Json(m.name);
      mj["value"] = Json(m.value);
      mj["timestamp"] = Json(m.timestamp);
      mArr ~= mj;
    }
    jj["metrics"] = mArr;

    return jj;
  }
}
