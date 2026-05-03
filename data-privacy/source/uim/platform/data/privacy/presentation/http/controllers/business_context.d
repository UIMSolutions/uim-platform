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
  private ManageBusinessContextsUseCase uc;

  this(ManageBusinessContextsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/business-contexts", &handleCreate);
    router.get("/api/v1/business-contexts", &handleList);
    router.get("/api/v1/business-contexts/*", &handleGetById);
    router.put("/api/v1/business-contexts/*", &handleUpdate);
    router.post("/api/v1/business-contexts/*/activate", &handleActivate);
    router.delete_("/api/v1/business-contexts/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateBusinessContextRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.controllerGroupId = j.getString("controllerGroupId");
      r.dataCategories = getStringArray(j, "dataCategories");
      r.purposes = getStringArray(j, "purposes");
      r.dataCategoryAttributes = getStringArray(j, "dataCategoryAttributes");
      r.isCrossRoleEnabled = j.getBoolean("isCrossRoleEnabled", false);

      auto result = uc.createContext(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Business context created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listContexts(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", Json(items.length))
          .set("message", "Business contexts retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getContext(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Business context not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateBusinessContextRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.dataCategories = getStringArray(j, "dataCategories");
      r.purposes = getStringArray(j, "purposes");
      r.dataCategoryAttributes = getStringArray(j, "dataCategoryAttributes");
      r.isCrossRoleEnabled = j.getBoolean("isCrossRoleEnabled", false);

      auto result = uc.updateContext(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Business context updated");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      ActivateBusinessContextRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;

      auto result = uc.activateContext(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Business context activated");
            
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      uc.deleteContext(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const BusinessContext e) {
    auto cats = e.dataCategories.map!(c => Json(c)).array.toJson;

    auto purps = e.purposes.map!(p => Json(p)).array.toJson;

    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("name", e.name)
      .set("description", e.description)
      .set("controllerGroupId", e.controllerGroupId)
      .set("status", e.status.to!string)
      .set("version", e.version_)
      .set("isCrossRoleEnabled", e.isCrossRoleEnabled)
      .set("createdAt", e.createdAt)
      .set("updatedAt", e.updatedAt)
      .set("activatedAt", e.activatedAt)
      .set("dataCategories", cats)
      .set("purposes", purps);
  }
}
