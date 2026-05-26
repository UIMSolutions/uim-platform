/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.http.controllers.flex_applications;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Routes: /api/v2/applications
class FlexApplicationsController : ManageController {
  private ManageFlexApplicationsUseCase usecase;

  this(ManageFlexApplicationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v2/applications",         &handleList);
    router.get("/api/v2/applications/*",       &handleGet);
    router.post("/api/v2/applications",        &handleCreate);
    router.put("/api/v2/applications/*",       &handleUpdate);
    router.delete_("/api/v2/applications/*",   &handleDelete);
  }

  private static void writeError(scope HTTPServerResponse res, int status, string msg) {
    res.writeJsonBody(Json.emptyObject.set("error", msg).set("status", status), status);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateFlexApplicationRequest r;
      r.tenantId       = tenantId;
      r.applicationId  = FlexApplicationId(j.getString("id"));
      r.namespace_     = j.getString("namespace");
      r.appId          = j.getString("appId");
      r.description_   = j.getString("description");
      r.isActive_      = j.get("isActive", Json(true)).get!bool;
      r.validFrom_     = j.getString("validFrom");
      r.validTo_       = j.getString("validTo");
      r.owner_         = j.getString("owner");
      r.version_       = j.getString("version");
      auto result = usecase.createApplication(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("status", "created"), 201);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      FlexApplication[] apps;
      auto activeParam = req.query.get("active", "");
      if (activeParam == "true")
        apps = usecase.listActiveApplications(tenantId);
      else
        apps = usecase.listApplications(tenantId);
      auto arr = Json.emptyArray;
      foreach (a; apps) arr ~= a.toJson();
      res.writeJsonBody(Json.emptyObject.set("applications", arr).set("count", apps.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = FlexApplicationprecheck.id);
      auto a = usecase.getApplication(tenantId, id);
      if (a.isNull) { writeError(res, 404, "FlexApplication not found"); return; }
      res.writeJsonBody(a.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = FlexApplicationprecheck.id);
      auto j = req.json;
      UpdateFlexApplicationRequest r;
      r.tenantId       = tenantId;
      r.applicationId  = id;
      r.description_   = j.getString("description");
      r.isActive_      = j.get("isActive", Json(true)).get!bool;
      r.validFrom_     = j.getString("validFrom");
      r.validTo_       = j.getString("validTo");
      r.owner_         = j.getString("owner");
      r.version_       = j.getString("version");
      auto result = usecase.updateApplication(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = FlexApplicationprecheck.id);
      auto result = usecase.deleteApplication(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
