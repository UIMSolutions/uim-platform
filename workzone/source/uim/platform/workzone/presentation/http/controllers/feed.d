/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.feed;



// import uim.platform.workzone.application.usecases.manage.feeds;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.feed_entry;
// import uim.platform.identity.authentication.presentation.http
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class FeedController : ManageController {
    private ManageFeedsUseCase useCase;

    this(ManageFeedsUseCase useCase) {
      this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router) {
      super.registerRoutes(router);

      router.post("/api/v1/feeds", &handleCreate);
      router.get("/api/v1/feeds", &handleList);
      router.get("/api/v1/feeds/*", &handleGet);
      router.delete_("/api/v1/feeds/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
      try {
        auto j = req.json;
        auto r = CreateFeedEntryRequest();
        r.workspaceId = data.getString("workspaceId");
        r.tenantId = tenantId;
        r.actorId = data.getString("actorId");
        r.actorName = data.getString("actorName");
        r.action = data.getString("action");
        r.objectType = data.getString("objectType");
        r.objectId = data.getString("objectId");
        r.objectTitle = data.getString("objectTitle");
        r.message = data.getString("message");

        auto result = useCase.createEntry(r);
        if (result.isSuccess()) {
          auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Feed entry created");

          res.writeJsonBody(resp, 201);
        } else {
          writeError(res, 400, result.message);
        }
      } catch (Exception e) {
        writeError(res, 500, "Internal server error");
      }
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
      try {
        auto tenantId = precheck.tenantId;
        auto workspaceId = req.params.get("workspaceId", "");
        auto entries = useCase.listByWorkspace(workspacetenantId, id);
        auto arr = entries.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", Json(entries.length))
          .set("message", "Feed entries retrieved successfully");

        res.writeJsonBody(resp, 200);
      } catch (Exception e) {
        writeError(res, 500, "Internal server error");
      }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
      try {
        auto id = precheck.id;
        auto tenantId = precheck.tenantId;
        auto entry = useCase.getEntry(tenantId, id);
        if (entry.isNull) {
          writeError(res, 404, "Feed entry not found");
          return;
        }
        res.writeJsonBody(entry.toJson, 200);
      } catch (Exception e) {
        writeError(res, 500, "Internal server error");
      }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
      try {
        auto id = precheck.id;
        auto tenantId = precheck.tenantId;
        useCase.deleteEntry(tenantId, id);
        res.writeBody("", 204);
      } catch (Exception e) {
        writeError(res, 500, "Internal server error");
      }
    }
  }

private Json serializeFeed(FeedEntry e) {
  return Json.emptyObject
    .set("id", e.id)
    .set("workspaceId", e.workspaceId)
    .set("tenantId", e.tenantId)
    .set("actorId", e.actorId)
    .set("actorName", e.actorName)
    .set("action", e.action)
    .set("objectType", e.objectType)
    .set("objectId", e.objectId)
    .set("objectTitle", e.objectTitle)
    .set("message", e.message)
    .set("createdAt", e.createdAt);
}
