/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.prompt;

// import uim.platform.ai_launchpad.application.usecases.manage.prompts;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class PromptController : ManageController {
  private ManagePromptsUseCase usecase;

  this(ManagePromptsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/genai/prompts", &handleCreate);
    router.get("/api/v1/genai/prompts", &handleList);
    router.get("/api/v1/genai/prompts/*", &handleGet);
    router.patch("/api/v1/genai/prompts/*", &handlePatch);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreatePromptRequest r;
r.tenantId = tenantId;
      r.collectionId = data.getString("collectionId");
      r.name = data.getString("name");
      r.modelName = data.getString("modelName");
      r.modelVersion = data.getString("modelVersion");
      r.messages = jsonMessageArray(j, "messages");
      r.temperature = getDouble(j, "temperature");
      r.maxTokens = data.getInteger("maxTokens");
      r.topP = getDouble(j, "topP");
      r.frequencyPenalty = getDouble(j, "frequencyPenalty");
      r.presencePenalty = getDouble(j, "presencePenalty");
      r.inputParams = data.getStrings("inputParams");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = usecase.createPrompt(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Prompt created");

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
      auto collectionId = PromptCollectionId(req.headers.get("X-Collection-Id", ""));

      auto prompts = collectionId.isEmpty
        ? usecase.listPrompts(tenantId) : usecase.listPrompts(tenantId, collectionId);

      auto jarr = prompts.map!(p => p.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", prompts.length)
        .set("resources", jarr)
        .set("message", "Prompts retrieved");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = PromptId(precheck.id);

      auto p = usecase.getPrompt(tenantId, id);
      if (p.isNull) {
        writeError(res, 404, "Prompt not found");
        return;
      }

      res.writeJsonBody(p.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = PromptId(precheck.id);
      auto data = precheck.data;
      PatchPromptRequest r;
      r.tenantId = tenantId;
      r.promptId = id;
      r.name = data.getString("name");
      r.status = data.getString("status");
      r.messages = jsonMessageArray(j, "messages");
      r.temperature = getDouble(j, "temperature");
      r.maxTokens = data.getInteger("maxTokens");

      auto result = usecase.patchPrompt(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", id)
          .set("message", "Prompt updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
