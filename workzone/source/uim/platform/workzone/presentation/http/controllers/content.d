/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.content;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.content;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.content_item;

class ContentController : PlatformController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateContentRequest();
      r.workspaceId = j.getString("workspaceId");
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.summary = j.getString("summary");
      r.authorId = j.getString("authorId");
      r.authorName = j.getString("authorName");
      r.tags = getStringArray(j, "tags");
      r.language = j.getString("language");

      auto ctStr = j.getString("contentType");
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
      auto query = req.params.get("q", "");
      ContentItem[] items;
      if (query.length > 0)
        items = useCase.searchContent(workspacetenantId, id, query);
      else
        items = useCase.listByWorkspace(workspacetenantId, id);

      auto arr = items.map!(c => serializeContent(c)).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Content items retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto item = useCase.getContent(tenantId, id);
      if (item.isNull) {
        writeError(res, 404, "Content not found");
        return;
      }
      res.writeJsonBody(serializeContent(*item), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = UpdateContentRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.summary = j.getString("summary");
      r.tags = getStringArray(j, "tags");
      r.pinned = j.getBoolean("pinned");

      auto statusStr = j.getString("status");
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
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      useCase.deleteContent(tenantId, id);
      res.writeBody("", 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePublish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.publishContent(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "published");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

private Json serializeContent(ContentItem c) {
  // import std.conv : to;
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
