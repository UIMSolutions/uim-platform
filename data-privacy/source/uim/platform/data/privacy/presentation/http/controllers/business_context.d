/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.business_context;
// import uim.platform.data.privacy.application.usecases.manage.business_contexts;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.business_context;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class BusinessContextController : PlatformController {
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

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreateBusinessContextRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.controllerGroupId = j.getString("controllerGroupId");
      r.dataCategories = j.getStrings("dataCategories");
      r.purposes = j.getStrings("purposes");
      r.dataCategoryAttributes = j.getStrings("dataCategoryAttributes");
      r.isCrossRoleEnabled = j.getBoolean("isCrossRoleEnabled", false);

      auto result = usecase.createContext(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Business context created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto items = usecase.listContexts(tenantId);
      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Business contexts retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = BusinessContextId(extractIdFromPath(req.requestURI));

      auto entry = usecase.getContext(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Business context not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      UpdateBusinessContextRequest r;
      r.tenantId = tenantId;
      r.contextId = BusinessContextId(extractIdFromPath(req.requestURI));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.dataCategories = j.getStrings("dataCategories");
      r.purposes = j.getStrings("purposes");
      r.dataCategoryAttributes = j.getStrings("dataCategoryAttributes");
      r.isCrossRoleEnabled = j.getBoolean("isCrossRoleEnabled", false);

      auto result = usecase.updateContext(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Business context updated");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      ActivateBusinessContextRequest r;
      r.contextId = BusinessContextId(extractIdFromPath(req.requestURI));
      r.tenantId = tenantId;

      auto result = usecase.activateContext(r);
      if (result.isSuccess()) { 
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Business context activated");
            
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto contextId = BusinessContextId(extractIdFromPath(req.requestURI));

      usecase.deleteContext(tenantId, contextId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
