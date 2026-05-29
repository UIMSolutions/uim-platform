/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.http.controllers.flex_versions;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Routes: /keyuser/v2/versions
class FlexVersionsController : ManageController {
  private ManageFlexVersionsUseCase usecase;

  this(ManageFlexVersionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/keyuser/v2/versions",         &handleList);
    router.get("/keyuser/v2/versions/*",       &handleGet);
    router.post("/keyuser/v2/versions",        &handleCreate);
    router.put("/keyuser/v2/versions/*",       &handleUpdate);
    router.post("/keyuser/v2/versions/*/activate", &handleActivate);
    router.delete_("/keyuser/v2/versions/*",   &handleDelete);
  }

  private static void writeError(scope HTTPServerResponse res, int status, string msg) {
    res.writeJsonBody(Json.emptyObject.set("error", msg).set("status", status), status);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateFlexVersionRequest r;
      r.tenantId    = tenantId;
      r.versionId   = FlexVersionId(precheck.id);
      r.appId       = data.getString("appId");
      r.displayName_ = data.getString("displayName");
      r.description_ = data.getString("description");
      r.activatedBy_ = data.getString("activatedBy");
      auto idsArr = j.get("changeIds", Json.emptyArray);
      foreach (cid; idsArr) r.changeIds_ ~= cid.get!string;
      auto result = usecase.createVersion(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("status", "created"), 201);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      // Path: /keyuser/v2/versions/{id}/activate — extract id from segment before /activate
      auto fullPath = req.requestURI.to!string;
      import std.string : lastIndexOf;
      auto activateIdx = fullPath.lastIndexOf("/activate");
      if (activateIdx < 0) { writeError(res, 400, "Invalid activate path"); return; }
      auto basePath2 = fullPath[0 .. activateIdx];
      auto id = FlexVersionId(extractIdFromPath(basePath2));
      auto data = precheck.data;
      ActivateVersionRequest r;
      r.tenantId    = tenantId;
      r.versionId   = id;
      r.appId       = data.getString("appId");
      r.activatedBy_ = data.getString("activatedBy");
      auto result = usecase.activateVersion(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("status", "activated"), 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      FlexVersion[] versions;
      auto appParam = req.query.get("appId", "");
      if (appParam.length > 0)
        versions = usecase.listVersionsByApp(tenantId, appParam);
      else
        versions = usecase.listVersions(tenantId);
      auto arr = Json.emptyArray;
      foreach (v; versions) arr ~= v.toJson();
      res.writeJsonBody(Json.emptyObject.set("versions", arr).set("count", versions.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = FlexVersionId(precheck.id);
      auto v = usecase.getVersion(tenantId, id);
      if (v.isNull) { writeError(res, 404, "FlexVersion not found"); return; }
      res.writeJsonBody(v.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = FlexVersionId(precheck.id);
      auto data = precheck.data;
      UpdateFlexVersionRequest r;
      r.tenantId    = tenantId;
      r.versionId   = id;
      r.displayName_ = data.getString("displayName");
      r.description_ = data.getString("description");
      r.status_ = VersionStatus.draft_;
      auto result = usecase.updateVersion(r);
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
      auto tenantId = precheck.tenantId;
      auto id = FlexVersionId(precheck.id);
      auto result = usecase.deleteVersion(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
