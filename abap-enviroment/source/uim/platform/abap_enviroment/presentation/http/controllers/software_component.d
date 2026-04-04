/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.http.controllers.software_component;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.abap_enviroment.application.usecases.manage.software_components;
// import uim.platform.abap_enviroment.application.dto;
// import uim.platform.abap_enviroment.domain.entities.software_component;
// import uim.platform.abap_enviroment.domain.types;
// import uim.platform.abap_enviroment.presentation.http.json_utils;

import uim.platform.abap_enviroment;

mixin(ShowModule!());
@safe:
class SoftwareComponentController : SAPController
{
  private ManageSoftwareComponentsUseCase uc;

  this(ManageSoftwareComponentsUseCase uc)
  {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router)
  {
    super.registerRoutes(router);

    router.post("/api/v1/software-components", &handleCreate);
    router.get("/api/v1/software-components", &handleList);
    router.get("/api/v1/software-components/*", &handleGetById);
    router.post("/api/v1/software-components/clone/*", &handleClone);
    router.post("/api/v1/software-components/pull/*", &handlePull);
    router.delete_("/api/v1/software-components/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      CreateSoftwareComponentRequest request;
      request.tenantId = req.headers.get("X-Tenant-Id", "");
      request.systemInstanceId = j.getString("systemInstanceId");
      request.name = j.getString("name");
      request.description = j.getString("description");
      request.componentType = j.getString("componentType");
      request.repositoryUrl = j.getString("repositoryUrl");
      request.branch = j.getString("branch");
      request.branchStrategy = j.getString("branchStrategy");
      request.namespace = j.getString("namespace");

      auto result = uc.createComponent(request);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto systemId = req.json.getString("systemInstanceId");
      if (systemId.length == 0)
        systemId = req.headers.get("X-System-Id", "");
      auto components = uc.listComponents(systemId);
      auto arr = Json.emptyArray;
      foreach (ref comp; components)
        arr ~= serializeComponent(comp);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) components.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto comp = uc.getComponent(id);
      if (comp is null)
      {
        writeError(res, 404, "Software component not found");
        return;
      }
      res.writeJsonBody(serializeComponent(*comp), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleClone(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      CloneSoftwareComponentRequest r;
      r.branch = j.getString("branch");
      r.commitId = j.getString("commitId");

      auto result = uc.cloneComponent(id, r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("cloned");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePull(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      PullSoftwareComponentRequest r;
      r.commitId = j.getString("commitId");

      auto result = uc.pullComponent(id, r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("pulled");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteComponent(id);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("deleted");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeComponent(ref const SoftwareComponent comp)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(comp.id);
    j["tenantId"] = Json(comp.tenantId);
    j["systemInstanceId"] = Json(comp.systemInstanceId);
    j["name"] = Json(comp.name);
    j["description"] = Json(comp.description);
    j["componentType"] = Json(comp.componentType.to!string);
    j["status"] = Json(comp.status.to!string);
    j["repositoryUrl"] = Json(comp.repositoryUrl);
    j["branch"] = Json(comp.branch);
    j["branchStrategy"] = Json(comp.branchStrategy.to!string);
    j["currentCommitId"] = Json(comp.currentCommitId);
    j["namespace"] = Json(comp.namespace);
    j["clonedAt"] = Json(comp.clonedAt);
    j["lastPulledAt"] = Json(comp.lastPulledAt);
    j["createdAt"] = Json(comp.createdAt);
    j["updatedAt"] = Json(comp.updatedAt);

    if (comp.commitHistory.length > 0)
    {
      auto hist = Json.emptyArray;
      foreach (ref c; comp.commitHistory)
      {
        auto hj = Json.emptyObject;
        hj["commitId"] = Json(c.commitId);
        hj["message"] = Json(c.message);
        hj["author"] = Json(c.author);
        hj["timestamp"] = Json(c.timestamp);
        hist ~= hj;
      }
      j["commitHistory"] = hist;
    }

    return j;
  }
}
