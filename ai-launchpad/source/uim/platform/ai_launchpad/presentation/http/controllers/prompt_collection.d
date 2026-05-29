/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.prompt_collection;

// import uim.platform.ai_launchpad.application.usecases.manage.prompt_collections;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class PromptCollectionController : ManageController {
  private ManagePromptCollectionsUseCase usecase;

  this(ManagePromptCollectionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/genai/prompt-collections", &handleCreate);
    router.get("/api/v1/genai/prompt-collections", &handleList);
    router.get("/api/v1/genai/prompt-collections/*", &handleGet);
    router.patch("/api/v1/genai/prompt-collections/*", &handlePatch);
    router.delete_("/api/v1/genai/prompt-collections/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreatePromptCollectionRequest r;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.scenarioId = data.getString("scenarioId");
    r.workspaceId = data.getString("workspaceId");

    auto result = usecase.createCollection(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Prompt collection created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto workspaceId = WorkspaceId(req.headers.get("X-Workspace-Id", ""));

    auto collections = workspaceId.isEmpty
      ? usecase.listCollections(tenantId) : usecase.listCollections(tenantId, workspaceId);

    auto list = collections.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Prompt collection list retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = PromptCollectionId(precheck.id);
    if (id.isNull)
      return errorResponse("Prompt collection ID is required", 400);

    auto c = usecase.getCollection(tenantId, id);
    if (c.isNull)
      return errorResponse("Prompt collection not found", 404);

    auto responseData = c.toJson();
    return successResponse("Prompt collection retrieved successfully", 200, responseData);
  }

  override protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PromptCollectionId(precheck.id);
    auto data = precheck.data;
    PatchPromptCollectionRequest r;
    r.tenantId = tenantId;
    r.collectionId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");

    auto result = usecase.patchCollection(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Prompt collection updated");

    return successResponse("Prompt collection updated successfully", 200, resp);
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto resp = patchHandler(req);
      res.writeJsonBody(resp, resp.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = PromptCollectionId(precheck.id);
    if (id.isNull)
      return errorResponse("Prompt collection ID is required", 400);

    auto result = usecase.deleteCollection(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Prompt collection deleted successfully", 200, responseData);
  }
}
