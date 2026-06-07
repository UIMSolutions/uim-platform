/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.business_context;
// import uim.platform.data.privacy.application.usecases.manage.business_contexts;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.business_context;
import uim.platform.data.privacy;

// mixin(ShowModule!());

@safe:
class BusinessContextController : ManageHttpController {
  private ManageBusinessContextsUseCase usecase;

  this(ManageBusinessContextsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/business-contexts", &handleCreate);
    router.get("/api/v1/business-contexts", &handleList);
    router.get("/api/v1/business-contexts/*", &handleGet);
    router.put("/api/v1/business-contexts/*", &handleUpdate);
    router.post("/api/v1/business-contexts/*/activate", &handleActivate);
    router.delete_("/api/v1/business-contexts/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateBusinessContextRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.controllerGroupId = data.getString("controllerGroupId");
    r.dataCategories = data.getStrings("dataCategories");
    r.purposes = data.getStrings("purposes");
    r.dataCategoryAttributes = data.getStrings("dataCategoryAttributes");
    r.isCrossRoleEnabled = data.getBoolean("isCrossRoleEnabled", false);

    auto result = usecase.createContext(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Business context created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listContexts(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Business context list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BusinessContextId(precheck.id);

    auto entry = usecase.getContext(tenantId, id);
    if (entry.isNull)
      return errorResponse("Business context not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Business context retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    UpdateBusinessContextRequest r;
    r.tenantId = tenantId;
    r.contextId = BusinessContextId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.dataCategories = data.getStrings("dataCategories");
    r.purposes = data.getStrings("purposes");
    r.dataCategoryAttributes = data.getStrings("dataCategoryAttributes");
    r.isCrossRoleEnabled = data.getBoolean("isCrossRoleEnabled", false);

    auto result = usecase.updateContext(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Business context updated successfully", "Updated", 200, responseData);
  }

  protected Json activateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    ActivateBusinessContextRequest r;
    r.contextId = BusinessContextId(precheck.id);
    r.tenantId = tenantId;

    auto result = usecase.activateContext(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Business context activated successfully", "Activated", 200, responseData);
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = activateHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto contextId = BusinessContextId(precheck.id);

    auto result = usecase.deleteContext(tenantId, contextId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Business context deleted successfully", "Deleted", 200, responseData);
  }
}
