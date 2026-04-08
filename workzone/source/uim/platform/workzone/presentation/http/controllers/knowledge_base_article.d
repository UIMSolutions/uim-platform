/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.knowledge_base_article;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.knowledge_base_articles;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.knowledge_base_article;
import uim.platform.identity_authentication.presentation.http.json_utils;

class KnowledgeBaseArticleController {
  private ManageKnowledgeBaseArticlesUseCase useCase;

  this(ManageKnowledgeBaseArticlesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/kb-articles", &handleCreate);
    router.get("/api/v1/kb-articles", &handleList);
    router.get("/api/v1/kb-articles/*", &handleGet);
    router.put("/api/v1/kb-articles/*", &handleUpdate);
    router.delete_("/api/v1/kb-articles/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateKBArticleRequest();
      r.tenantId = req.getTenantId;
      r.workspaceId = j.getString("workspaceId");
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.summary = j.getString("summary");
      r.authorId = j.getString("authorId");
      r.authorName = j.getString("authorName");
      r.category = j.getString("category");
      r.tags = jsonStrArray(j, "tags");
      r.language = j.getString("language");

      auto result = useCase.createArticle(r);
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
      auto articles = useCase.listByWorkspace(workspaceId, tenantId);
      auto arr = Json.emptyArray;
      foreach (ref a; articles)
        arr ~= serializeKBArticle(a);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) articles.length);
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
      auto a = useCase.getArticle(id, tenantId);
      if (a is null) {
        writeError(res, 404, "Article not found");
        return;
      }
      res.writeJsonBody(serializeKBArticle(*a), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateKBArticleRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.summary = j.getString("summary");
      r.category = j.getString("category");
      r.tags = jsonStrArray(j, "tags");

      auto result = useCase.updateArticle(r);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteArticle(id, tenantId);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
