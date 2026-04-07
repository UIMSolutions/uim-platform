/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.business_subprocess;

// import uim.platform.data.privacy.application.usecases.manage.business_subprocesses;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.business_subprocess;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class BusinessSubprocessController : SAPController {
  private ManageBusinessSubprocessesUseCase uc;

  this(ManageBusinessSubprocessesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/business-subprocesses", &handleCreate);
    router.get("/api/v1/business-subprocesses", &handleList);
    router.get("/api/v1/business-subprocesses/*", &handleGetById);
    router.put("/api/v1/business-subprocesses/*", &handleUpdate);
    router.delete_("/api/v1/business-subprocesses/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateBusinessSubprocessRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.parentProcessId = j.getString("parentProcessId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.purposes = jsonStrArray(j, "purposes");
      r.dataCategories = jsonStrArray(j, "dataCategories");
      r.owner = j.getString("owner");

      auto result = uc.createSubprocess(r);
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listSubprocesses(tenantId);

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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto entry = uc.getSubprocess(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "Business subprocess not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateBusinessSubprocessRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.purposes = jsonStrArray(j, "purposes");
      r.dataCategories = jsonStrArray(j, "dataCategories");
      r.owner = j.getString("owner");

      auto result = uc.updateSubprocess(r);
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      uc.deleteSubprocess(id, tenantId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(ref const BusinessSubprocess e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["parentProcessId"] = Json(e.parentProcessId);
    j["name"] = Json(e.name);
    j["description"] = Json(e.description);
    j["owner"] = Json(e.owner);
    j["isActive"] = Json(e.isActive);
    j["createdAt"] = Json(e.createdAt);
    j["updatedAt"] = Json(e.updatedAt);

    auto purps = Json.emptyArray;
    foreach (ref p; e.purposes) purps ~= Json(p);
    j["purposes"] = purps;

    auto cats = Json.emptyArray;
    foreach (ref c; e.dataCategories) cats ~= Json(c);
    j["dataCategories"] = cats;

    return j;
  }
}
