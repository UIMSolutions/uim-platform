/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.artifact;

// import uim.platform.ai_core.application.usecases.manage.artifacts;
// import uim.platform.ai_core.application.dto;

// import uim.platform.ai_core;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class ArtifactController : PlatformController {
  private ManageArtifactsUseCase usecase;

  this(ManageArtifactsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v2/lm/artifacts", &handleCreate);
    router.get("/api/v2/lm/artifacts", &handleList);
    router.get("/api/v2/lm/artifacts/*", &handleGet);
    router.delete_("/api/v2/lm/artifacts/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto j = req.json;
      CreateArtifactRequest r;
      r.tenantId = tenantId;
      r.resourceGroupId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      r.scenarioId = j.getString("scenarioId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.kind = j.getString("kind");
      r.url = j.getString("url");
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = usecase.createArtifact(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Artifact registered");

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
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      auto scenarioId = req.params.get("scenarioId", "");

      auto artifacts = scenarioId.isEmpty
        ? usecase.listArtifacts(tenantId, rgId)
        : usecase.listArtifacts(tenantId, rgId, scenarioId);

      auto jarr = artifacts.map!(a => a.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", artifacts.length)
        .set("resources", jarr)
        .set("message", "Artifacts retrieved");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ArtifactId(extractIdFromPath(req.requestURI.to!string));
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

      auto a = usecase.getArtifact(tenantId, rgId, id);
      if (a.isNull) {
        writeError(res, 404, "Artifact not found");
        return;
      }

      res.writeJsonBody(a.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ArtifactId(extractIdFromPath(req.requestURI.to!string));
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

      auto result = usecase.deleteArtifact(tenantId, rgId, id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("status", "deleted")
          .set("message", "Artifact deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
