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

class TrainingJobController : ManageController {
  private ManageTrainingJobsUseCase usecase;

  this(ManageTrainingJobsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/training/jobs", &handleCreate);
    router.get("/api/v1/training/jobs", &handleList);
    router.get("/api/v1/training/jobs/*", &handleGet);
    router.patch("/api/v1/training/jobs/*", &handlePatch);
    router.delete_("/api/v1/training/jobs/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;

      CreateTrainingJobRequest r;
      r.tenantId = tenantId;
      r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
      r.documentTypeId = data.getString("documentTypeId");
      r.schemaId = data.getString("schemaId");
      r.name = data.getString("name");
      r.description = data.getString("description");

      auto result = usecase.createTrainingJob(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Training job created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
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
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;

      PatchTrainingJobRequest r;
      r.tenantId = tenantId;
      r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
      r.trainingJobId = id;
      r.targetStatus = data.getString("targetStatus");

      auto result = usecase.patchTrainingJob(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Training job updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

      auto result = usecase.deleteTrainingJob(tenantId, id, clientId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
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
