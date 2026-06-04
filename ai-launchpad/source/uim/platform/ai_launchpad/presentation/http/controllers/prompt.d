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

class PromptController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreatePromptRequest r;
    r.tenantId = tenantId;
    r.collectionId = data.getString("collectionId");
    r.name = data.getString("name");
    r.modelName = data.getString("modelName");
    r.modelVersion = data.getString("modelVersion");
    r.messages = jsonMessageArray(data, "messages");
    r.temperature = data.getDouble("temperature");
    r.maxTokens = data.getInteger("maxTokens");
    r.topP = data.getDouble("topP");
    r.frequencyPenalty = data.getDouble("frequencyPenalty");
    r.presencePenalty = data.getDouble("presencePenalty");
    r.inputParams = data.getStrings("inputParams");
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = usecase.createPrompt(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Prompt created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto collectionId = PromptCollectionId(req.headers.get("X-Collection-Id", ""));

    auto prompts = collectionId.isEmpty
      ? usecase.listPrompts(tenantId) 
      : usecase.listPrompts(tenantId, collectionId);

    auto list = prompts.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Prompt list retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PromptId(precheck.id);
    if (id.isNull)
      return errorResponse("Prompt ID is required", 400);

    auto p = usecase.getPrompt(tenantId, id);
    if (p.isNull)
      return errorResponse("Prompt not found", 404);

    auto responseData = p.toJson();
    return successResponse("Prompt retrieved successfully", 200, responseData);
  }

  protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PromptId(precheck.id);
    if (id.isNull)
      return errorResponse("Prompt ID is required", 400);

    auto data = precheck.data;
    PatchPromptRequest r;
    r.tenantId = tenantId;
    r.promptId = id;
    r.name = data.getString("name");
    r.status = data.getString("status");
    r.messages = jsonMessageArray(data, "messages");
    r.temperature = data.getDouble("temperature");
    r.maxTokens = data.getInteger("maxTokens");
    r.topP = data.getDouble("topP");
    r.frequencyPenalty = data.getDouble("frequencyPenalty");
    r.presencePenalty = data.getDouble("presencePenalty");
    r.inputParams = data.getStrings("inputParams");

    auto result = usecase.patchPrompt(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Prompt updated successfully", 200, responseData);
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = patchHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
