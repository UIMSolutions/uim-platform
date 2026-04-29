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

class TrainingJobController : PlatformController {
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
      r.tenantId = req.getTenantId;
      r.clientId = req.headers.get("X-Client-Id", "");
      r.documentTypeId = j.getString("documentTypeId");
      r.schemaId = j.getString("schemaId");
      r.name = j.getString("name");
      r.description = j.getString("description");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", Json("Training job created"));

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
      auto clientId = req.headers.get("X-Client-Id", "");
      auto jobs = uc.list(clientId);

      auto jarr = Json.emptyArray;
      foreach (tj; jobs) {
        jarr ~= jobToJson(tj);
      }

      auto resp = Json.emptyObject
        .set("count", Json(jobs.length))
        .set("resources", jarr)
        .set("message", Json("Training job list retrieved successfully"));

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

      auto tj = uc.getById(id, clientId);
      if (tj.id.isEmpty) {
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
      r.tenantId = req.getTenantId;
      r.clientId = req.headers.get("X-Client-Id", "");
      r.trainingJobId = id;
      r.targetStatus = j.getString("targetStatus");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", Json("Training job updated"));
          
        res.writeJsonBody(resp, 200);
      } else {
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
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json jobToJson(TrainingJob tj) {
    auto mArr = Json.emptyArray;
    foreach (m; tj.metrics) {
      auto mj = Json.emptyObject;
      mj["name"] = Json(m.name);
      mj["value"] = Json(m.value);
      mj["timestamp"] = Json(m.timestamp);
      mArr ~= mj;
    }

    return Json.emptyObject
      .set("id", tj.id)
      .set("documentTypeId", tj.documentTypeId)
      .set("schemaId", tj.schemaId)
      .set("name", tj.name)
      .set("description", tj.description)
      .set("modelVersion", tj.modelVersion)
      .set("status", tj.status.to!string)
      .set("statusMessage", tj.statusMessage)
      .set("documentCount", tj.documentCount)
      .set("accuracy", tj.accuracy)
      .set("startedAt", tj.startedAt)
      .set("completedAt", tj.completedAt)
      .set("createdAt", tj.createdAt)
      .set("updatedAt", tj.updatedAt)
      .set("metrics", mArr);
  }
}
