/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.software_component;
// 
// 
// import uim.platform.abap_environment.application.usecases.manage.software_components;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.software_component;


import uim.platform.abap_environment;

// mixin(ShowModule!());
@safe:
class SoftwareComponentController : ManageController {
  private ManageSoftwareComponentsUseCase usecase;

  this(ManageSoftwareComponentsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/software-components", &handleCreate);
    router.get("/api/v1/software-components", &handleList);
    router.get("/api/v1/software-components/*", &handleGet);
    router.post("/api/v1/software-components/clone/*", &handleClone);
    router.post("/api/v1/software-components/pull/*", &handlePull);
    router.delete_("/api/v1/software-components/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto systemId = SystemInstanceId(req.json.getString("systemInstanceId"));
    if (systemId.isEmpty)
      systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));

    auto items = usecase.listSoftwareComponents(tenantId, systemId);
    auto arr = items.map!(comp => comp.toJson).array.toJson;

    return Json.emptyObject
      .set("status", 200)
      .set("items", arr)
      .set("totalCount", items.length)
      .set("message", "Software components retrieved successfully")
      .set("statusCode", 200);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateSoftwareComponentRequest request;
    request.tenantId = tenantId;
    request.systemInstanceId = SystemInstanceId(data.getString("systemInstanceId"));
    request.name = data.getString("name");
    request.description = data.getString("description");
    request.componentType = data.getString("componentType");
    request.repositoryUrl = data.getString("repositoryUrl");
    request.branch = data.getString("branch");
    request.branchStrategy = data.getString("branchStrategy");
    request.namespace = data.getString("namespace");

    auto result = usecase.createSoftwareComponent(request);
    if (result.hasError()) {
      return Json.emptyObject
        .set("status", 400)
        .set("statusCode", 400)
        .set("error", result.message)
        .set("message", "Failed to create software component");
    }

    return Json.emptyObject
      .set("id", result.id)
      .set("status", 201)
      .set("statusCode", 201)
      .set("message", "Software component created");
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto id = SoftwareComponentId(precheck.id);

    auto comp = usecase.getSoftwareComponent(tenantId, id);
    if (comp.isNull) {
      return Json.emptyObject
        .set("status", 404)
        .set("statusCode", 404)
        .set("error", "Software component not found")
        .set("message", "Software component not found");
    }

    return Json.emptyObject
      .set("status", 200)
      .set("statusCode", 200)
      .set("item", comp.toJson)
      .set("message", "Software component retrieved successfully");
  }

  protected Json cloneHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SoftwareComponentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid software component ID", 400);

    auto data = precheck.data;
    CloneSoftwareComponentRequest request;
    request.tenantId = tenantId;
    request.componentId = id;
    request.branch = data.getString("branch");
    request.commitId = data.getString("commitId");

    auto result = usecase.cloneSoftwareComponent(request);
    if (result.hasError())
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Software component cloned successfully", "Cloned", 200, responseData);
  }

  protected void handleClone(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = cloneHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json pullHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SoftwareComponentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid software component ID", 400);

    auto data = precheck.data;
    PullSoftwareComponentRequest r;
    r.tenantId = tenantId;
    r.softwareComponentId = id;
    r.commitId = data.getString("commitId");

    auto result = usecase.pullSoftwareComponent(r);
    if (result.hasError())
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Software component pulled successfully", "Pulled", 200, responseData);
  }

  protected void handlePull(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = pullHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto id = SoftwareComponentId(precheck.id);

    auto result = usecase.deleteSoftwareComponent(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Software component deleted successfully", "Deleted", 200, responseData);
  }
}
