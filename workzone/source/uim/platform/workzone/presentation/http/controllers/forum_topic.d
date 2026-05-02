/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.forum_topic;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.forum_topics;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.forum_topic;

class ForumTopicController : PlatformController {
  private ManageForumTopicsUseCase useCase;

  this(ManageForumTopicsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/forum-topics", &handleCreate);
    router.get("/api/v1/forum-topics", &handleList);
    router.get("/api/v1/forum-topics/*", &handleGet);
    router.put("/api/v1/forum-topics/*", &handleUpdate);
    router.delete_("/api/v1/forum-topics/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateForumTopicRequest();
      r.tenantId = req.getTenantId;
      r.workspaceId = j.getString("workspaceId");
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.authorId = j.getString("authorId");
      r.authorName = j.getString("authorName");
      r.tags = getStringArray(j, "tags");

      auto result = useCase.createForumTopic(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto workspaceId = req.params.get("workspaceId", "");
      auto topics = useCase.listByWorkspace(workspacetenantId, id);
      auto arr = topics.map!(t => serializeForumTopic(t)).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", topics.length)
        .set("message", "Forum topics retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto t = useCase.getForumTopic(tenantId, id);
      if (t.isNull) {
        writeError(res, 404, "Forum topic not found");
        return;
      }
      res.writeJsonBody(t.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateForumTopicRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.pinned = j.getBoolean("pinned");
      r.locked = j.getBoolean("locked");

      auto result = useCase.updateForumTopic(r);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteForumTopic(tenantId, id);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
