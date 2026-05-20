/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.http.controllers.flex_drafts;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Routes: /keyuser/v2/drafts
class FlexDraftsController : PlatformController {
  private ManageFlexDraftsUseCase usecase;

  this(ManageFlexDraftsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/keyuser/v2/drafts",         &handleList);
    router.get("/keyuser/v2/drafts/*",       &handleGet);
    router.post("/keyuser/v2/drafts",        &handleCreate);
    router.put("/keyuser/v2/drafts/*",       &handleUpdate);
    router.delete_("/keyuser/v2/drafts/*",   &handleDelete);
  }

  private static void writeError(scope HTTPServerResponse res, int status, string msg) {
    res.writeJsonBody(Json.emptyObject.set("error", msg).set("status", status), status);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateFlexDraftRequest r;
      r.tenantId       = tenantId;
      r.draftId        = FlexDraftId(j.getString("id"));
      r.appId          = j.getString("appId");
      r.updatedBy_     = j.getString("updatedBy");
      r.baseVersionId_ = j.getString("baseVersionId");
      auto result = usecase.createDraft(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("status", "created"), 201);
      else
        writeError(res, 400, result.errorMessage);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto drafts = usecase.listDrafts(tenantId);
      auto arr = Json.emptyArray;
      foreach (d; drafts) arr ~= d.toJson();
      res.writeJsonBody(Json.emptyObject.set("drafts", arr).set("count", drafts.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = FlexDraftId(extractIdFromPath(req.requestURI.to!string));
      auto d = usecase.getDraft(tenantId, id);
      if (d.isNull) { writeError(res, 404, "FlexDraft not found"); return; }
      res.writeJsonBody(d.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = FlexDraftId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;
      UpdateFlexDraftRequest r;
      r.tenantId   = tenantId;
      r.draftId    = id;
      r.updatedBy_ = j.getString("updatedBy");
      auto idsArr = j.get("changeIds", Json.emptyArray);
      foreach (cid; idsArr) r.changeIds_ ~= cid.get!string;
      auto result = usecase.updateDraft(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, 400, result.errorMessage);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = FlexDraftId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.discardDraft(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.errorMessage);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
