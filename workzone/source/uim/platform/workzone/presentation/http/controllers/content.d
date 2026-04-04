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
import uim.platform.identity_authentication.presentation.http.json_utils;

class ContentController
{
  private ManageContentUseCase useCase;

  this(ManageContentUseCase useCase)
  {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/content", &handleCreate);
    router.get("/api/v1/content", &handleList);
    router.get("/api/v1/content/*", &handleGet);
    router.put("/api/v1/content/*", &handleUpdate);
    router.delete_("/api/v1/content/*", &handleDelete);
    router.post("/api/v1/content/publish/*", &handlePublish);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateContentRequest();
      r.workspaceId = j.getString("workspaceId");
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.summary = j.getString("summary");
      r.authorId = j.getString("authorId");
      r.authorName = j.getString("authorName");
      r.tags = jsonStrArray(j, "tags");
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
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto workspaceId = req.params.get("workspaceId", "");
      auto query = req.params.get("q", "");
      ContentItem[] items;
      if (query.length > 0)
        items = useCase.searchContent(workspaceId, tenantId, query);
      else
        items = useCase.listByWorkspace(workspaceId, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref c; items)
        arr ~= serializeContent(c);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto item = useCase.getContent(id, tenantId);
      if (item is null)
      {
        writeError(res, 404, "Content not found");
        return;
      }
      res.writeJsonBody(serializeContent(*item), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = UpdateContentRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.summary = j.getString("summary");
      r.tags = jsonStrArray(j, "tags");
      r.pinned = j.getBoolean("pinned");

      auto statusStr = j.getString("status");
      if (statusStr == "published")
        r.status = ContentStatus.published;
      else if (statusStr == "archived")
        r.status = ContentStatus.archived;
      else
        r.status = ContentStatus.draft;

      auto result = useCase.updateContent(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      useCase.deleteContent(id, tenantId);
      res.writeBody("", 204);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePublish(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.publishContent(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("published");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }
}

private Json serializeContent(ref ContentItem c)
{
  // import std.conv : to;
  auto j = Json.emptyObject;
  j["id"] = Json(c.id);
  j["workspaceId"] = Json(c.workspaceId);
  j["tenantId"] = Json(c.tenantId);
  j["title"] = Json(c.title);
  j["body"] = Json(c.body_);
  j["summary"] = Json(c.summary);
  j["contentType"] = Json(c.contentType.to!string);
  j["status"] = Json(c.status.to!string);
  j["authorId"] = Json(c.authorId);
  j["authorName"] = Json(c.authorName);
  j["language"] = Json(c.language);
  j["viewCount"] = Json(c.viewCount);
  j["likeCount"] = Json(c.likeCount);
  j["pinned"] = Json(c.pinned);
  j["commentsEnabled"] = Json(c.commentsEnabled);
  j["publishedAt"] = Json(c.publishedAt);
  j["createdAt"] = Json(c.createdAt);
  j["updatedAt"] = Json(c.updatedAt);

  auto tags = Json.emptyArray;
  foreach (ref t; c.tags)
    tags ~= Json(t);
  j["tags"] = tags;

  return j;
}
