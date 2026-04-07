/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.artifact;

import uim.platform.ai_core.application.usecases.manage.artifacts;
import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

class ArtifactController : SAPController {
  private ManageArtifactsUseCase uc;

  this(ManageArtifactsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v2/lm/artifacts", &handleCreate);
    router.get("/api/v2/lm/artifacts", &handleList);
    router.get("/api/v2/lm/artifacts/*", &handleGet);
    router.delete_("/api/v2/lm/artifacts/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateArtifactRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.resourceGroupId = req.headers.get("AI-Resource-Group", "");
      r.scenarioId = j.getString("scenarioId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.kind = j.getString("kind");
      r.url = j.getString("url");
      r.labels = jsonKeyValuePairs(j, "labels");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Artifact registered");
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
      auto rgId = req.headers.get("AI-Resource-Group", "");
      auto scenarioId = req.params.get("scenarioId", "");

      typeof(uc.list(rgId)) artifacts;
      if (scenarioId.length > 0)
        artifacts = uc.listByScenario(scenarioId, rgId);
      else
        artifacts = uc.list(rgId);

      auto jarr = Json.emptyArray;
      foreach (ref a; artifacts) {
        jarr ~= artifactToJson(a);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) artifacts.length);
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
      auto rgId = req.headers.get("AI-Resource-Group", "");

      auto a = uc.get_(id, rgId);
      if (a.id.length == 0) {
        writeError(res, 404, "Artifact not found");
        return;
      }

      res.writeJsonBody(artifactToJson(a), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto rgId = req.headers.get("AI-Resource-Group", "");

      auto result = uc.remove(id, rgId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json artifactToJson(ref Artifact a) {
    import std.conv : to;

    auto aj = Json.emptyObject;
    aj["id"] = Json(a.id);
    aj["scenarioId"] = Json(a.scenarioId);
    aj["executionId"] = Json(a.executionId);
    aj["name"] = Json(a.name);
    aj["description"] = Json(a.description);
    aj["kind"] = Json(a.kind.to!string);
    aj["url"] = Json(a.url);
    aj["createdAt"] = Json(a.createdAt);
    aj["modifiedAt"] = Json(a.modifiedAt);

    auto lArr = Json.emptyArray;
    foreach (ref lbl; a.labels) {
      auto lj = Json.emptyObject;
      lj["key"] = Json(lbl.key);
      lj["value"] = Json(lbl.value);
      lArr ~= lj;
    }
    aj["labels"] = lArr;

    return aj;
  }
}
