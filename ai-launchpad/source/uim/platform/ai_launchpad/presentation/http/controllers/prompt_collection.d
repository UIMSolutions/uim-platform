/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.prompt_collection;

import uim.platform.ai_launchpad.application.usecases.manage.prompt_collections;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

class PromptCollectionController : PlatformController {
  private ManagePromptCollectionsUseCase uc;

  this(ManagePromptCollectionsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/genai/prompt-collections", &handleCreate);
    router.get("/api/v1/genai/prompt-collections", &handleList);
    router.get("/api/v1/genai/prompt-collections/*", &handleGet);
    router.patch("/api/v1/genai/prompt-collections/*", &handlePatch);
    router.delete_("/api/v1/genai/prompt-collections/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;

      CreatePromptCollectionRequest r;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.scenarioId = j.getString("scenarioId");
      r.workspaceId = j.getString("workspaceId");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Prompt collection created");
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
      auto workspaceId = req.headers.get("X-Workspace-Id", "");

      typeof(uc.listAll()) collections;
      if (workspaceId.length > 0)
        collections = uc.listByWorkspace(workspaceId);
      else
        collections = uc.listAll();

      auto jarr = Json.emptyArray;
      foreach (c; collections) {
        jarr ~= serializeCollection(c);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(collections.length);
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

      auto c = uc.getById(id);
      if (c.id.isEmpty) {
        writeError(res, 404, "Prompt collection not found");
        return;
      }

      res.writeJsonBody(serializeCollection(c), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      PatchPromptCollectionRequest r;
      r.collectionId = id;
      r.name = j.getString("name");
      r.description = j.getString("description");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["message"] = Json("Prompt collection updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id = extractIdFromPath(req.requestURI.to!string);

      auto result = uc.remove(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeCollection(PromptCollection c) {
    return Json.emptyObject
      .set("id", Json(c.id))
      .set("name", Json(c.name))
      .set("description", Json(c.description))
      .set("scenarioId", Json(c.scenarioId))
      .set("workspaceId", Json(c.workspaceId))
      .set("promptCount", Json(c.promptCount))
      .set("createdAt", Json(c.createdAt))
      .set("modifiedAt", Json(c.modifiedAt));
  }
}
