/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.feed;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.feeds;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.feed_entry;
import uim.platform.identity_authentication.presentation.http.json_utils;

class FeedController {
  private ManageFeedsUseCase useCase;

  this(ManageFeedsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/feeds", &handleCreate);
    router.get("/api/v1/feeds", &handleList);
    router.get("/api/v1/feeds/*", &handleGet);
    router.delete_("/api/v1/feeds/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateFeedEntryRequest();
      r.workspaceId = j.getString("workspaceId");
      r.tenantId = req.getTenantId;
      r.actorId = j.getString("actorId");
      r.actorName = j.getString("actorName");
      r.action = j.getString("action");
      r.objectType = j.getString("objectType");
      r.objectId = j.getString("objectId");
      r.objectTitle = j.getString("objectTitle");
      r.message = j.getString("message");

      auto result = useCase.createEntry(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto workspaceId = req.params.get("workspaceId", "");
      auto entries = useCase.listByWorkspace(workspaceId, tenantId);
      auto arr = Json.emptyArray;
      foreach (ref e; entries)
        arr ~= serializeFeed(e);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) entries.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = useCase.getEntry(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "Feed entry not found");
        return;
      }
      res.writeJsonBody(serializeFeed(*entry), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      useCase.deleteEntry(id, tenantId);
      res.writeBody("", 204);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

private Json serializeFeed(ref FeedEntry e) {
  auto j = Json.emptyObject;
  j["id"] = Json(e.id);
  j["workspaceId"] = Json(e.workspaceId);
  j["tenantId"] = Json(e.tenantId);
  j["actorId"] = Json(e.actorId);
  j["actorName"] = Json(e.actorName);
  j["action"] = Json(e.action);
  j["objectType"] = Json(e.objectType);
  j["objectId"] = Json(e.objectId);
  j["objectTitle"] = Json(e.objectTitle);
  j["message"] = Json(e.message);
  j["createdAt"] = Json(e.createdAt);
  return j;
}
