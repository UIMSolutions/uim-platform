/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.training_job;

// import uim.platform.document_ai.application.usecases.manage.training_jobs;
// import uim.platform.document_ai.application.dto;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.training_job : TrainingJob;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class TrainingJobController : PlatformController {
  private ManageTrainingJobsUseCase usecase;

  this(ManageTrainingJobsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/training/jobs", &handleCreate);
    router.get("/api/v1/training/jobs", &handleList);
    router.get("/api/v1/training/jobs/*", &handleGet);
    router.patch_("/api/v1/training/jobs/*", &handlePatch);
    router.delete_("/api/v1/training/jobs/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreateTrainingJobRequest r;
      r.tenantId = tenantId;
      r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
      r.documentTypeId = j.getString("documentTypeId");
      r.schemaId = j.getString("schemaId");
      r.name = j.getString("name");
      r.description = j.getString("description");

      auto result = usecase.createTrainingJob(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Training job created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));
      auto jobs = usecase.listTrainingJobs(tenantId, clientId);

      auto jarr = jobs.map!(tj => jobToJson(tj)).array.toJson;

      auto resp = Json.emptyObject
        .set("count", jobs.length)
        .set("resources", jarr)
        .set("message", "Training job list retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

      auto tj = usecase.getTrainingJob(tenantId, id, clientId);
      if (tj.isNull) {
        writeError(res, 404, "Training job not found");
        return;
      }

      res.writeJsonBody(jobToJson(tj), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      PatchTrainingJobRequest r;
      r.tenantId = tenantId;
      r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
      r.trainingJobId = id;
      r.targetStatus = j.getString("targetStatus");

      auto result = usecase.patchTrainingJob(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Training job updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

      auto result = usecase.deleteTrainingJob(tenantId, id, clientId, id);
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
      mArr ~= Json.emptyObject
        .set("name", m.name)
        .set("value", m.value)
        .set("timestamp", m.timestamp);
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
