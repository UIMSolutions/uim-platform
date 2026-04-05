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
import uim.platform.identity_authentication.presentation.http.json_utils;

class ForumTopicController {
  private ManageForumTopicsUseCase useCase;

  this(ManageForumTopicsUseCase useCase)
  {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/forum-topics", &handleCreate);
    router.get("/api/v1/forum-topics", &handleList);
    router.get("/api/v1/forum-topics/*", &handleGet);
    router.put("/api/v1/forum-topics/*", &handleUpdate);
    router.delete_("/api/v1/forum-topics/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateForumTopicRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.workspaceId = j.getString("workspaceId");
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.authorId = j.getString("authorId");
      r.authorName = j.getString("authorName");
      r.tags = jsonStrArray(j, "tags");

      auto result = useCase.createForumTopic(r);
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
      auto topics = useCase.listByWorkspace(workspaceId, tenantId);
      auto arr = Json.emptyArray;
      foreach (ref t; topics)
        arr ~= serializeForumTopic(t);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) topics.length);
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
      auto t = useCase.getForumTopic(id, tenantId);
      if (t is null)
      {
        writeError(res, 404, "Forum topic not found");
        return;
      }
      res.writeJsonBody(serializeForumTopic(*t), 200);
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
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateForumTopicRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.pinned = jsonBool(j, "pinned");
      r.locked = jsonBool(j, "locked");

      auto result = useCase.updateForumTopic(r);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
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
      auto result = useCase.deleteForumTopic(id, tenantId);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }
}
