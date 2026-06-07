/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.http.controllers.flex_drafts;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

/// Routes: /keyuser/v2/drafts
class FlexDraftsController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
              CreateFlexDraftRequest r;
      r.tenantId       = tenantId;
      r.draftId        = FlexDraftId(precheck.id);
      r.appId          = data.getString("appId");
      r.updatedBy_     = data.getString("updatedBy");
      r.baseVersionId_ = data.getString("baseVersionId");
      auto result = usecase.createDraft(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id).set("status", "created"), 201);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto drafts = usecase.listDrafts(tenantId);
      auto arr = Json.emptyArray;
      foreach (d; drafts) arr ~= d.toJson();
      res.writeJsonBody(Json.emptyObject.set("drafts", arr).set("count", drafts.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = FlexDraftId(precheck.id);
      auto d = usecase.getDraft(tenantId, id);
      if (d.isNull) { writeError(res, 404, "FlexDraft not found"); return; }
      res.writeJsonBody(d.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = FlexDraftId(precheck.id);
      auto data = precheck.data;
      UpdateFlexDraftRequest r;
      r.tenantId   = tenantId;
      r.draftId    = id;
      r.updatedBy_ = data.getString("updatedBy");
      auto idsArr = j.get("changeIds", Json.emptyArray);
      foreach (cid; idsArr) r.changeIds_ ~= cid.get!string;
      auto result = usecase.updateDraft(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = FlexDraftId(precheck.id);
      auto result = usecase.discardDraft(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
