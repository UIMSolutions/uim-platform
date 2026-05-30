/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.catalog;


// import uim.platform.portal.application.usecases.manage.catalogs;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.catalog;
// import uim.platform.portal.domain.types;
import uim.platform.portal.application.usecases.manage;

import uim.platform.portal;

mixin(ShowModule!());

@safe:
class CatalogController : ManageController {
  private ManageCatalogsUseCase useCase;

  this(ManageCatalogsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/catalogs", &handleCreate);
    router.get("/api/v1/catalogs", &handleList);
    router.get("/api/v1/catalogs/*", &handleGet);
    router.put("/api/v1/catalogs/*", &handleUpdate);
    router.delete_("/api/v1/catalogs/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto createReq = CreateCatalogRequest(req.headers.get("X-Tenant-Id", ""),
        data.getString("title"), data.getString("description"), data.getString("providerId"),
        data.getStrings("allowedRoleIds"), data.getBoolean("active", true),);

      auto result = useCase.createCatalog(createReq);
      if (result.isSuccess()) {
        auto response = Json.emptyObject
          .set("id", result.catalogId);

        res.writeJsonBody(response, 201);
      } else {
        writeApiError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto catalogs = useCase.listCatalogs(tenantId);
      auto response = Json.emptyObject
        .set("totalResults", catalogs.length)
        .set("resources", catalogs);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto catalogId = precheck.id;
      if (!useCase.existsCatalog(catalogId)) {
        writeApiError(res, 404, "Catalog not found");
        return;
      }

      auto catalog = useCase.getCatalog(catalogId).toJson;
      res.writeJsonBody(catalog, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto catalogId = precheck.id;
      auto data = precheck.data;
      auto updateReq = UpdateCatalogRequest(catalogId, data.getString("title"),
        data.getString("description"), data.getStrings("allowedRoleIds"),
        data.getBoolean("active", true),);

      auto error = useCase.updateCatalog(updateReq);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto catalogId = precheck.id;
      auto error = useCase.deleteCatalog(catalogId);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }
}
