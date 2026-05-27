/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.content;



// import uim.platform.workzone.application.usecases.manage.content;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.content_item;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ContentController : ManageController {
  private ManageContentUseCase useCase;

  this(ManageContentUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/content", &handleCreate);
    router.get("/api/v1/content", &handleList);
    router.get("/api/v1/content/*", &handleGet);
    router.put("/api/v1/content/*", &handleUpdate);
    router.delete_("/api/v1/content/*", &handleDelete);
    router.post("/api/v1/content/publish/*", &handlePublish);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateContentRequest();
      r.workspaceId = data.getString("workspaceId");
      r.tenantId = tenantId;
      r.title = data.getString("title");
      r.body_ = data.getString("body");
      r.summary = data.getString("summary");
      r.authorId = data.getString("authorId");
      r.authorName = data.getString("authorName");
      r.tags = data.getStrings("tags");
      r.language = data.getString("language");

      auto ctStr = data.getString("contentType");
      if (ctStr == "wikiPage")
        r.contentType = ContentType.wikiPage;
      else if (ctStr == "knowledgeBase")
        r.contentType = ContentType.knowledgeBase;
      else if (ctStr == "forumPost")
        r.contentType = ContentType.forumPost;
      else if (ctStr == "announcement")
        r.contentType = ContentType.announcement;
      else if (ctStr == "document")
        r.contentType = ContentType.document;
      else
        r.contentType = ContentType.blogPost;

      auto result = useCase.createContent(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Content created");

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
      auto query = req.params.get("q", "");
      ContentItem[] items;
      if (query.length > 0)
        items = useCase.searchContent(workspacetenantId, id, query);
      else
        items = useCase.listByWorkspace(workspacetenantId, id);

      auto arr = items.map!(c => c.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Content items retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto item = useCase.getContent(tenantId, id);
      if (item.isNull) {
        writeError(res, 404, "Content not found");
        return;
      }
      res.writeJsonBody(item.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = UpdateContentRequest();
      r.id = precheck.id;
      r.tenantId = tenantId;
      r.title = data.getString("title");
      r.body_ = data.getString("body");
      r.summary = data.getString("summary");
      r.tags = data.getStrings("tags");
      r.pinned = data.getBoolean("pinned");

      auto statusStr = data.getString("status");
      if (statusStr == "published")
        r.status = ContentStatus.published;
      else if (statusStr == "archived")
        r.status = ContentStatus.archived;
      else
        r.status = ContentStatus.draft;

      auto result = useCase.updateContent(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "updated");

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
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      useCase.deleteContent(tenantId, id);
      res.writeBody("", 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePublish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.publishContent(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "published");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

private Json serializeContent(ContentItem c) {
  
  auto tags = c.tags.map!(t => t.toJson).array.toJson;

  return Json.emptyObject
    .set("id", c.id)
    .set("workspaceId", c.workspaceId)
    .set("tenantId", c.tenantId)
    .set("title", c.title)
    .set("body", c.body_)
    .set("summary", c.summary)
    .set("contentType", c.contentType.to!string)
    .set("status", c.status.to!string)
    .set("authorId", c.authorId)
    .set("authorName", c.authorName)
    .set("language", c.language)
    .set("viewCount", c.viewCount)
    .set("likeCount", c.likeCount)
    .set("pinned", c.pinned)
    .set("commentsEnabled", c.commentsEnabled)
    .set("publishedAt", c.publishedAt)
    .set("createdAt", c.createdAt)
    .set("updatedAt", c.updatedAt)
    .set("tags", tags);
}
