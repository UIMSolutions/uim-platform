/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.namespace;

// import uim.platform.credential_store.application.usecases.manage.usecase;
// import uim.platform.credential_store.application.dto;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:

class NamespaceController : PlatformController {
  private ManageNamespacesUseCase usecase;

  this(ManageNamespacesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/usecase", &handleCreate);
    router.get("/api/v1/usecase", &handleList);
    router.get("/api/v1/usecase/*", &handleGet);
    router.put("/api/v1/usecase/*", &handleUpdate);
    router.delete_("/api/v1/usecase/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreateNamespaceRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.createdBy = UserId(j.getString("createdBy"));

      auto result = usecase.createNamespace(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Namespace created successfully");

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

      auto namespaces = usecase.listNamespaces(tenantId);
      auto jarr = Json.emptyArray;
      foreach (ns; namespaces) {
        jarr ~= Json.emptyObject
          .set("id", ns.id)
          .set("name", ns.name)
          .set("description", ns.description)
          .set("createdAt", ns.createdAt);
      }

      auto resp = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", namespaces.length)
        .set("message", "Namespace list retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = NamespaceId(extractIdFromPath(req.requestURI.to!string));

      auto ns = usecase.getNamespace(tenantId, id);
      if (ns.isNull) {
        writeError(res, 404, "Namespace not found");
        return;
      }

      auto nj = Json.emptyObject
        .set("id", ns.id)
        .set("tenantId", ns.tenantId)
        .set("name", ns.name)
        .set("description", ns.description)
        .set("createdAt", ns.createdAt)
        .set("updatedAt", ns.updatedAt)
        .set("createdBy", ns.createdBy);

      res.writeJsonBody(nj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = NamespaceId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;

      UpdateNamespaceRequest r;
      r.tenantId = tenantId;
      r.namespaceId = id;
      r.description = j.getString("description");

      auto result = usecase.updateNamespace(tenantId, id, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Namespace updated successfully");

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
      auto id = NamespaceId(extractIdFromPath(req.requestURI.to!string));

      auto result = usecase.deleteNamespace(tenantId, id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
