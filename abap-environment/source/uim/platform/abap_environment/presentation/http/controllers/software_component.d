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
class SoftwareComponentController : PlatformController {
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

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateSoftwareComponentRequest request;
      request.tenantId = req.getTenantId;
      request.systemInstanceId = j.getString("systemInstanceId");
      request.name = j.getString("name");
      request.description = j.getString("description");
      request.componentType = j.getString("componentType");
      request.repositoryUrl = j.getString("repositoryUrl");
      request.branch = j.getString("branch");
      request.branchStrategy = j.getString("branchStrategy");
      request.namespace = j.getString("namespace");

      auto result = usecase.createComponent(request);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto systemId = SystemInstanceId(req.json.getString("systemInstanceId"));
      if (systemId.isEmpty)
        systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));

      auto items = usecase.listComponents(systemId);
      auto arr = items.map!(comp => comp.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Software components retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = SoftwareComponentId(extractIdFromPath(req.requestURI));
      auto comp = usecase.getComponent(id);
      if (comp.isNull) {
        writeError(res, 404, "Software component not found");
        return;
      }
      res.writeJsonBody(comp.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetClone(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = SoftwareComponentId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      CloneSoftwareComponentRequest r;
      r.branch = j.getString("branch");
      r.commitId = j.getString("commitId");

      auto result = usecase.cloneComponent(id, r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "cloned");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetPull(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = SoftwareComponentId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      PullSoftwareComponentRequest r;
      r.commitId = j.getString("commitId");

      auto result = usecase.pullComponent(id, r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "pulled");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = SoftwareComponentId(extractIdFromPath(req.requestURI));
      auto result = usecase.deleteComponent(id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
