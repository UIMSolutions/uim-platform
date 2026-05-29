/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.executable;
// import uim.platform.ai_core.application.usecases.manage.executables;
// import uim.platform.ai_core.application.dto;
// import uim.platform.ai_core;
import uim.platform.ai_core;

mixin(ShowModule!());

@safe:
class ExecutableController : ManageController {
  private ManageExecutablesUseCase usecase;

  this(ManageExecutablesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v2/lm/executables", &handleList);
    router.get("/api/v2/lm/executables/*", &handleGet);
    router.post("/api/v2/lm/executables", &handleCreate);
    router.delete_("/api/v2/lm/executables/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateExecutableRequest r;
    r.tenantId = tenantId;
    r.resourceGroupId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    r.scenarioId = ScenarioId(data.getString("scenarioId"));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.type = data.getString("type");
    r.versionId = data.getString("versionId");
    r.deployable = data.getString("deployable");

    auto result = usecase.createExecutable(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Executable created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    auto scenarioId = ScenarioId(req.params.get("scenarioId", ""));

    auto executables = scenarioId.isEmpty
      ? usecase.listExecutables(tenantId, rgId) : usecase.listExecutables(tenantId, rgId, scenarioId);

    auto list = Json.emptyArray;
    foreach (e; executables) {
      list ~= Json.emptyObject
        .set("id", e.id)
        .set("scenarioId", e.scenarioId)
        .set("name", e.name)
        .set("description", e.description)
        .set("type", e.type == ExecutableType.serving ? "serving" : "workflow")
        .set("versionId", e.versionId)
        .set("deployable", e.deployable)
        .set("createdAt", e.createdAt)
        .set("updatedAt", e.updatedAt);
    }

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Executables retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ExecutableId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid executable ID");

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto e = usecase.getExecutable(tenantId, rgId, id);
    if (e.isNull)
      return errorResponse("Scan job not found", 404);

    auto responseData = Json.emptyObject
      .set("id", e.id)
      .set("scenarioId", e.scenarioId)
      .set("name", e.name)
      .set("description", e.description)
      .set("type", e.type == ExecutableType.serving ? "serving" : "workflow")
      .set("versionId", e.versionId)
      .set("deployable", e.deployable)
      .set("createdAt", e.createdAt)
      .set("updatedAt", e.updatedAt)
      .set("message", "Executable retrieved");

    return successResponse("Scan job retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ExecutableId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid executable ID");

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto result = usecase.deleteExecutable(tenantId, rgId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Executable deleted successfully", "Deleted", 200, responseData);
  }
}
