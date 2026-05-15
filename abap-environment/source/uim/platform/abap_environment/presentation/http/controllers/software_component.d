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
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

mixin(ShowModule!());
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

  override protected Json listHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto systemId = SystemInstanceId(req.json.getString("systemInstanceId"));
    if (systemId.isEmpty)
      systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));

    auto items = usecase.listComponents(systemId);
    auto arr = items.map!(comp => comp.toJson).array.toJson;

    return Json.emptyObject
      .set("status", 200)
      .set("items", arr)
      .set("totalCount", items.length)
      .set("message", "Software components retrieved successfully")
      .set("statusCode", 200);
  }

  override protected Json createHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto tenantId = req.getTenantId;
    auto j = req.json;

    CreateSoftwareComponentRequest request;
    request.tenantId = tenantId;
    request.systemInstanceId = j.getString("systemInstanceId");
    request.name = j.getString("name");
    request.description = j.getString("description");
    request.componentType = j.getString("componentType");
    request.repositoryUrl = j.getString("repositoryUrl");
    request.branch = j.getString("branch");
    request.branchStrategy = j.getString("branchStrategy");
    request.namespace = j.getString("namespace");

    auto result = usecase.createSoftwareComponent(request);
    if (result.isFailure()) {
      return Json.emptyObject
        .set("status", 400)
        .set("statusCode", 400)
        .set("error", result.error)
        .set("message", "Failed to create software component");
    }

    return Json.emptyObject
      .set("id", result.id)
      .set("status", 201)
      .set("statusCode", 201)
      .set("message", "Software component created");
  }

  override protected Json getHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto tenantId = req.getTenantId;
    auto id = SoftwareComponentId(extractIdFromPath(req.requestURI));

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

  protected void handleClone(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = SoftwareComponentId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      
      CloneSoftwareComponentRequest r;
      r.tenantId = tenantId;
      r.branch = j.getString("branch");
      r.commitId = j.getString("commitId");

      auto result = usecase.cloneSoftwareComponent(id, r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", 200)
          .set("statusCode", 200)
          .set("message", "Software component cloned successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePull(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = SoftwareComponentId(extractIdFromPath(req.requestURI));
      auto j = req.json;

      PullSoftwareComponentRequest r;
      r.tenantId = tenantId;
      r.commitId = j.getString("commitId");

      auto result = usecase.pullSoftwareComponent(id, r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", 200)
          .set("message", "Software component pulled successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto tenantId = req.getTenantId;
    auto id = SoftwareComponentId(extractIdFromPath(req.requestURI));

    auto result = usecase.deleteSoftwareComponent(tenantId, id);
    if (result.isFailure()) {
      return Json.emptyObject
        .set("status", 404)
        .set("error", result.error)
        .set("message", "Software component not found");
    }
    return Json.emptyObject
      .set("status", 200)
      .set("message", "Software component deleted successfully");
  }
}
