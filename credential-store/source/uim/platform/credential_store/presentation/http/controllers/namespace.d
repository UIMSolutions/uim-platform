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

class NamespaceController : ManageController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateNamespaceRequest r;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = usecase.createNamespace(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Namespace created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = NamespaceId(precheck.id);

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

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = NamespaceId(precheck.id);
      auto data = precheck.data;
      UpdateNamespaceRequest request;
      request.tenantId = tenantId;
      request.namespaceId = id;
      request.description = data.getString("description");

      auto result = usecase.updateNamespace(request);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Namespace updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = NamespaceId(precheck.id);

      auto result = usecase.deleteNamespace(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Namespace deleted successfully", 200, responseData);
  }
}
