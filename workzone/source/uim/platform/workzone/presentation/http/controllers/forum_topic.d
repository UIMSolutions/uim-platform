/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.forum_topic;



// import uim.platform.workzone.application.usecases.manage.forum_topics;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.forum_topic;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ForumTopicController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = CreateForumTopicRequest();
      r.tenantId = tenantId;
      r.workspaceId = j.getString("workspaceId");
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.authorId = j.getString("authorId");
      r.authorName = j.getString("authorName");
      r.tags = getStrings(j, "tags");

      auto result = useCase.createForumTopic(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Forum topic created");

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
      auto tenantId = req.getTenantId;
      auto workspaceId = req.params.get("workspaceId", "");
      auto topics = useCase.listByWorkspace(tenantId, workspaceId);
      auto arr = topics.map!(t => t.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", topics.length)
        .set("message", "Forum topics retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto tenantId = req.getTenantId;
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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto j = req.json;
      auto r = UpdateForumTopicRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.pinned = j.getBoolean("pinned");
      r.locked = j.getBoolean("locked");

      auto result = useCase.updateForumTopic(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Forum topic updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto tenantId = req.getTenantId;
      auto result = useCase.deleteForumTopic(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Forum topic deleted successfully");

        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
