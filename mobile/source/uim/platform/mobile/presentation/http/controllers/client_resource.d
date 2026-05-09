/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.client_resource;

import uim.platform.mobile.application.usecases.manage.client_resources;
import uim.platform.mobile.application.dto;

import uim.platform.mobile;



class ClientResourceController : PlatformController {
  private ManageClientResourcesUseCase usecase;

  this(ManageClientResourcesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/resources", &handleCreate);
    router.get("/api/v1/resources", &handleList);
    router.get("/api/v1/resources/*", &handleGet);
    router.put("/api/v1/resources/*", &handleUpdate);
    router.delete_("/api/v1/resources/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateClientResourceRequest r;
      r.tenantId = tenantId;
      r.appId = j.getString("appId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.contentType = j.getString("contentType");
      r.data = j.getString("data");
      r.createdBy = UserId(j.getString("createdBy"));
      auto result = usecase.create(r);
      if (result.success) {
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
      auto tenantId = req.getTenantId;
      auto results = usecase.list(tenantId);
      auto items = Json.emptyArray;
      foreach (item; results) {
        items ~= Json.emptyObject
          .set("id", item.id)
          .set("appId", item.appId)
          .set("name", item.name)
          .set("type", item.type)
          .set("contentType", item.contentType);
      }
      auto resp = Json.emptyObject
        .set("items", items)
        .set("totalCount", Json(results.length))
        .set("message", "Client resources retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = usecase.get(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.data.id))
          .set("tenantId", Json(result.data.tenantId))
          .set("appId", Json(result.data.appId))
          .set("name", Json(result.data.name))
          .set("description", Json(result.data.description))
          .set("type", Json(result.data.type))
          .set("contentType", Json(result.data.contentType))
          .set("data", Json(result.data.data))
          .set("createdBy", Json(result.data.createdBy))
          .set("message", "Client resource retrieved successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateClientResourceRequest r;
      r.id = id;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.contentType = j.getString("contentType");
      r.data = j.getString("data");
      r.updatedBy = UserId(j.getString("updatedBy"));
      auto result = usecase.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
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
      auto tenantId = req.getTenantId;
      auto id = ClientResourceId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.deleteClientResource(id);
      if (result.success) {
        res.writeBody("", 204);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
