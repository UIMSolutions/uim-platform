/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.buildpack;

// import uim.platform.foundry.application.usecases.manage.buildpacks;
// import uim.platform.foundry.application.dto;

// import uim.platform.foundry.domain.entities.buildpack;
import uim.platform.foundry;
mixin(ShowModule!());

@safe:

class BuildpackController : ManageHttpController {
  private ManageBuildpacksUseCase useCase;

  this(ManageBuildpacksUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/buildpacks", &handleCreate);
    router.get("/api/v1/buildpacks", &handleList);
    router.get("/api/v1/buildpacks/*", &handleGet);
    router.put("/api/v1/buildpacks/*", &handleUpdate);
    router.delete_("/api/v1/buildpacks/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateBuildpackRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.type_ = data.getString("type");
    r.position = data.getInteger("position");
    r.stack = data.getString("stack");
    r.filename = data.getString("filename");
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = useCase.createBuildpack(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Buildpack created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = useCase.listBuildpacks(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Buildpack list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BuildpackId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid buildpack ID", 400);

    auto bp = useCase.getBuildpack(tenantId, id);
    if (bp.isNull)
      return errorResponse("Buildpack not found", 404);

    auto responseData = bp.toJson();
    return successResponse("Buildpack retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BuildpackId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid buildpack ID", 400);

    auto data = precheck.data;
    auto r = UpdateBuildpackRequest();
    r.packId = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.position = data.getInteger("position");
    r.stack = data.getString("stack");
    r.filename = data.getString("filename");
    r.enabled = data.getBoolean("enabled", true);
    r.locked = data.getBoolean("locked");

    auto result = useCase.updateBuildpack(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Buildpack updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = BuildpackId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid buildpack ID", 400);

    auto result = useCase.deleteBuildpack(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Buildpack deleted successfully", "Deleted", 200, responseData);
  }
}
