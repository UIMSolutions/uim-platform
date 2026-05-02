/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.software_component;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.abap_environment.application.usecases.manage.software_components;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.software_component;
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:
class SoftwareComponentController : PlatformController {
  private ManageSoftwareComponentsUseCase uc;

  this(ManageSoftwareComponentsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/software-components", &handleCreate);
    router.get("/api/v1/software-components", &handleList);
    router.get("/api/v1/software-components/*", &handleGetById);
    router.post("/api/v1/software-components/clone/*", &handleClone);
    router.post("/api/v1/software-components/pull/*", &handlePull);
    router.delete_("/api/v1/software-components/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
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

      auto result = uc.createComponent(request);
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

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto systemId = req.json.getString("systemInstanceId");
      if (systemId.isEmpty)
        systemId = SystemInstanceId(req.headers.get("X-System-Id", ""));
      auto items = uc.listComponents(systemId);
      auto arr = items.map!(comp => serializeComponent(comp)).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Software components retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = SoftwareComponentId(extractIdFromPath(req.requestURI));
      auto comp = uc.getComponent(id);
      if (comp.isNull) {
        writeError(res, 404, "Software component not found");
        return;
      }
      res.writeJsonBody(comp.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleClone(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = SoftwareComponentId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      CloneSoftwareComponentRequest r;
      r.branch = j.getString("branch");
      r.commitId = j.getString("commitId");

      auto result = uc.cloneComponent(id, r);
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

  private void handlePull(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = SoftwareComponentId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      PullSoftwareComponentRequest r;
      r.commitId = j.getString("commitId");

      auto result = uc.pullComponent(id, r);
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

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = SoftwareComponentId(extractIdFromPath(req.requestURI));
      auto result = uc.deleteComponent(id);
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

  private static Json serializeComponent(const SoftwareComponent comp) {
    auto j = Json.emptyObject
      .set("id", comp.id)
      .set("tenantId", comp.tenantId)
      .set("systemInstanceId", comp.systemInstanceId)
      .set("name", comp.name)
      .set("description", comp.description)
      .set("componentType", comp.componentType.to!string)
      .set("status", comp.status.to!string)
      .set("repositoryUrl", comp.repositoryUrl)
      .set("branch", comp.branch)
      .set("branchStrategy", comp.branchStrategy.to!string)
      .set("currentCommitId", comp.currentCommitId)
      .set("namespace", comp.namespace)
      .set("clonedAt", comp.clonedAt)
      .set("lastPulledAt", comp.lastPulledAt)
      .set("createdAt", comp.createdAt)
      .set("updatedAt", comp.updatedAt);

    if (comp.commitHistory.length > 0) {
      auto hist = Json.emptyArray;
      foreach (c; comp.commitHistory) {
        hist ~= Json.emptyObject
          .set("commitId", c.commitId)
          .set("message", c.message)
          .set("author", c.author)
          .set("timestamp", c.timestamp);
      }
      j["commitHistory"] = hist;
    }

    return j;
  }
}
