/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.prompt;

import uim.platform.ai_launchpad.application.usecases.manage.prompts;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

class PromptController : SAPController {
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
      r.collectionId = jsonStr(j, "collectionId");
      r.name = jsonStr(j, "name");
      r.modelName = jsonStr(j, "modelName");
      r.modelVersion = jsonStr(j, "modelVersion");
      r.messages = jsonMessageArray(j, "messages");
      r.temperature = jsonDouble(j, "temperature");
      r.maxTokens = jsonInt(j, "maxTokens");
      r.topP = jsonDouble(j, "topP");
      r.frequencyPenalty = jsonDouble(j, "frequencyPenalty");
      r.presencePenalty = jsonDouble(j, "presencePenalty");
      r.inputParams = jsonStrArray(j, "inputParams");
      r.createdBy = jsonStr(j, "createdBy");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Prompt created");
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
      auto collectionId = req.headers.get("X-Collection-Id", "");

      typeof(uc.listAll()) prompts;
      if (collectionId.length > 0)
        prompts = uc.listByCollection(collectionId);
      else
        prompts = uc.listAll();

      auto jarr = Json.emptyArray;
      foreach (ref p; prompts) {
        jarr ~= serializePrompt(p);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) prompts.length);
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
      if (p.id.length == 0) {
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
      r.name = jsonStr(j, "name");
      r.status = jsonStr(j, "status");
      r.messages = jsonMessageArray(j, "messages");
      r.temperature = jsonDouble(j, "temperature");
      r.maxTokens = jsonInt(j, "maxTokens");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["message"] = Json("Prompt updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializePrompt(Prompt p) {
    import std.conv : to;
    import uim.platform.ai_launchpad.domain.entities.prompt : PromptMessage, PromptParameters;
    auto j = Json.emptyObject;
    j["id"] = Json(p.id);
    j["collectionId"] = Json(p.collectionId);
    j["name"] = Json(p.name);
    j["modelName"] = Json(p.modelName);
    j["modelVersion"] = Json(p.modelVersion);

    auto msgs = Json.emptyArray;
    foreach (ref m; p.messages) {
      auto mj = Json.emptyObject;
      mj["role"] = Json(m.role.to!string);
      mj["content"] = Json(m.content);
      msgs ~= mj;
    }
    j["messages"] = msgs;

    auto params = Json.emptyObject;
    params["temperature"] = Json(p.parameters.temperature);
    params["maxTokens"] = Json(cast(long) p.parameters.maxTokens);
    params["topP"] = Json(p.parameters.topP);
    params["frequencyPenalty"] = Json(p.parameters.frequencyPenalty);
    params["presencePenalty"] = Json(p.parameters.presencePenalty);
    j["parameters"] = params;

    j["inputParams"] = toJsonArray(p.inputParams);
    j["lastOutput"] = Json(p.lastOutput);
    j["status"] = Json(p.status.to!string);
    j["createdBy"] = Json(p.createdBy);
    j["createdAt"] = Json(p.createdAt);
    j["modifiedAt"] = Json(p.modifiedAt);
    return j;
  }
}
