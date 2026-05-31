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
class ArtifactController : ManageController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateArtifactRequest r;
    r.tenantId = tenantId;
    r.resourceGroupId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    r.scenarioId = ScenarioId(data.getString("scenarioId"));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.kind = data.getString("kind");
    r.url = data.getString("url");
    r.labels = jsonKeyValuePairs(data, "labels");

    auto result = usecase.createArtifact(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Artifact created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    auto scenarioId = ScenarioId(req.params.get("scenarioId", ""));

    auto artifacts = scenarioId.isEmpty
      ? usecase.listArtifacts(tenantId, rgId) : usecase.listArtifacts(tenantId, rgId, scenarioId);
    auto list = artifacts.map!(a => a.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);

    return successResponse("Artifact list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto id = ArtifactId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid artifact ID", 400);
    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto artefact = usecase.getArtifact(tenantId, rgId, id);
    if (artefact.isNull)
      return errorResponse("Artifact not found", 404);

    auto responseData = artefact.toJson();
    return successResponse("Artifact retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;

    auto id = ArtifactId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid artifact ID", 400);

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto result = usecase.deleteArtifact(tenantId, rgId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", id);

    return successResponse("Artifact deleted successfully", "Deleted", 200, resp);
  }
}
