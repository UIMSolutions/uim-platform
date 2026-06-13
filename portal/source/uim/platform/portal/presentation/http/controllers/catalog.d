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

// mixin(ShowModule!());

@safe:
class CatalogController : ManageHttpController {
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
    auto request = CreateCatalogRequest();
    request.tenantId = tenantId;
    request.title = data.getString("title");
    request.description = data.getString("description");
    request.providerId = data.getString("providerId");
    request.allowedRoleIds = data.getStrings("allowedRoleIds");
    request.active = data.getBoolean("active", true);

    auto result = useCase.createCatalog(request);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto response = Json.emptyObject
      .set("id", result.catalogId);

    return successResponse("Catalog created successfully", "Created", 201, response);
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

    return successResponse("Catalog list retrieved successfully", "OK", 200, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CatalogId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid catalog ID", 400);

    auto catalog = useCase.getCatalog(tenantId, id).toJson;
    if (catalog.isNull)

      return errorResponse("Catalog not found", 404);

    return successResponse("Catalog retrieved successfully", "OK", 200, catalog);

  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CatalogId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid catalog ID", 400);

    auto data = precheck.data;
    auto request = UpdateCatalogRequest;
    request.tenantId = tenantId;
    request.catalogId = id;
    request.title = data.getString("title");
    request.description = data.getString("description");
    request.allowedRoleIds = data.getStrings("allowedRoleIds");
    request.active = data.getBoolean("active", true);

    auto result = useCase.updateCatalog(request);
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Catalog updated successfully", "OK", 200, Json.emptyObject);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto catalogId = precheck.id;
    auto result = useCase.deleteCatalog(catalogId);
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Catalog deleted successfully", "OK", 200, Json.emptyObject);
  }
}

