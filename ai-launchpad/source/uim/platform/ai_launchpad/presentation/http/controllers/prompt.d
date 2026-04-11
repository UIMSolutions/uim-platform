/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.prompt;

import uim.platform.ai_launchpad.application.usecases.manage.prompts;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

class PromptController : PlatformController {
  private ManagePromptsUseCase uc;

  this(ManagePromptsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/genai/prompts", &handleCreate);
    router.get("/api/v1/genai/prompts", &handleList);
    router.get("/api/v1/genai/prompts/*", &handleGet);
    router.patch("/api/v1/genai/prompts/*", &handlePatch);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;

      CreatePromptRequest r;
      r.collectionId = j.getString("collectionId");
      r.name = j.getString("name");
      r.modelName = j.getString("modelName");
      r.modelVersion = j.getString("modelVersion");
      r.messages = jsonMessageArray(j, "messages");
      r.temperature = jsonDouble(j, "temperature");
      r.maxTokens = jsonInt(j, "maxTokens");
      r.topP = jsonDouble(j, "topP");
      r.frequencyPenalty = jsonDouble(j, "frequencyPenalty");
      r.presencePenalty = jsonDouble(j, "presencePenalty");
      r.inputParams = jsonStrArray(j, "inputParams");
      r.createdBy = j.getString("createdBy");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Prompt created");
        res.writeJsonBody(resp, 201);
      }) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto collectionId = req.headers.get("X-Collection-Id", "");

      typeof(uc.listAll()) prompts;
      if (collectionId.length > 0)
        prompts = uc.listByCollection(collectionId);
      else
        prompts = uc.listAll();

      auto jarr = Json.emptyArray;
      foreach (p; prompts) {
        jarr ~= serializePrompt(p);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(prompts.length);
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

      auto p = uc.get_(id);
      if (p.id.isEmpty) {
        writeError(res, 404, "Prompt not found");
        return;
      }

      res.writeJsonBody(serializePrompt(p), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;

      PatchPromptRequest r;
      r.promptId = id;
      r.name = j.getString("name");
      r.status = j.getString("status");
      r.messages = jsonMessageArray(j, "messages");
      r.temperature = jsonDouble(j, "temperature");
      r.maxTokens = jsonInt(j, "maxTokens");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["message"] = Json("Prompt updated");
        res.writeJsonBody(resp, 200);
      }) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializePrompt(Prompt p) {
    import std.conv : to;
    import uim.platform.ai_launchpad.domain.entities.prompt : PromptMessage, PromptParameters;

    auto msgs = Json.emptyArray;
    foreach (m; p.messages) {
      auto mj = Json.emptyObject;
      mj["role"] = Json(m.role.to!string);
      mj["content"] = Json(m.content);
      msgs ~= mj;
    }

    auto params = Json.emptyObject;
    params["temperature"] = Json(p.parameters.temperature);
    params["maxTokens"] = Json(p.parameters.maxTokens);
    params["topP"] = Json(p.parameters.topP);
    params["frequencyPenalty"] = Json(p.parameters.frequencyPenalty);
    params["presencePenalty"] = Json(p.parameters.presencePenalty);

    auto j = Json.emptyObject
      .set("id", p.id)
      .set("collectionId", p.collectionId)
      .set("name", p.name)
      .set("modelName", p.modelName)
      .set("modelVersion", p.modelVersion)
      .set("messages", msgs)
      .set("parameters", params)
      .set("inputParams", toJsonArray(p.inputParams))
      .set("lastOutput", Json(p.lastOutput))
      .set("status", Json(p.status.to!string))
      .set("createdBy", Json(p.createdBy))
      .set("createdAt", Json(p.createdAt))
      .set("modifiedAt", Json(p.modifiedAt));
  }
}
