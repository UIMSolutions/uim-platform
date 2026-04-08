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
class BusinessContextController : SAPController {
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
      r.dataCategories = jsonStrArray(j, "dataCategories");
      r.purposes = jsonStrArray(j, "purposes");
      r.dataCategoryAttributes = jsonStrArray(j, "dataCategoryAttributes");
      r.isCrossRoleEnabled = j.getBoolean("isCrossRoleEnabled", false);

      auto result = uc.createContext(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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

      auto arr = Json.emptyArray;
      foreach (ref e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getContext(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "Business context not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
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
      r.dataCategories = jsonStrArray(j, "dataCategories");
      r.purposes = jsonStrArray(j, "purposes");
      r.dataCategoryAttributes = jsonStrArray(j, "dataCategoryAttributes");
      r.isCrossRoleEnabled = j.getBoolean("isCrossRoleEnabled", false);

      auto result = uc.updateContext(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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
      uc.deleteContext(id, tenantId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(ref const BusinessContext e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["name"] = Json(e.name);
    j["description"] = Json(e.description);
    j["controllerGroupId"] = Json(e.controllerGroupId);
    j["status"] = Json(e.status.to!string);
    j["version"] = Json(cast(long) e.version_);
    j["isCrossRoleEnabled"] = Json(e.isCrossRoleEnabled);
    j["createdAt"] = Json(e.createdAt);
    j["updatedAt"] = Json(e.updatedAt);
    j["activatedAt"] = Json(e.activatedAt);

    auto cats = Json.emptyArray;
    foreach (ref c; e.dataCategories) cats ~= Json(c);
    j["dataCategories"] = cats;

    auto purps = Json.emptyArray;
    foreach (ref p; e.purposes) purps ~= Json(p);
    j["purposes"] = purps;

    return j;
  }
}
