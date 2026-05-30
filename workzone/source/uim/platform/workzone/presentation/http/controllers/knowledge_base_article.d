/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.knowledge_base_article;


// 
// import uim.platform.workzone.application.usecases.manage.knowledge_base_articles;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.knowledge_base_article;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class KnowledgeBaseArticleController : ManageController {
  private ManageKnowledgeBaseArticlesUseCase useCase;

  this(ManageKnowledgeBaseArticlesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/kb-articles", &handleCreate);
    router.get("/api/v1/kb-articles", &handleList);
    router.get("/api/v1/kb-articles/*", &handleGet);
    router.put("/api/v1/kb-articles/*", &handleUpdate);
    router.delete_("/api/v1/kb-articles/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateKBArticleRequest();
      r.tenantId = tenantId;
      r.workspaceId = data.getString("workspaceId");
      r.title = data.getString("title");
      r.body_ = data.getString("body");
      r.summary = data.getString("summary");
      r.authorId = data.getString("authorId");
      r.authorName = data.getString("authorName");
      r.category = data.getString("category");
      r.tags = data.getStrings("tags");
      r.language = data.getString("language");

      auto result = useCase.createArticle(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Knowledge base article created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto workspaceId = WorkspaceId(req.params.get("workspaceId", ""));

      auto articles = useCase.listByWorkspace(tenantId, workspaceId);
      auto arr = articles.map!(a => a.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(articles.length))
        .set("message", "Knowledge base articles retrieved successfully");

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
      auto a = useCase.getArticle(tenantId, id);
      if (a.isNull) {
        writeError(res, 404, "Article not found");
        return;
      }
      res.writeJsonBody(a.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = UpdateKBArticleRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.title = data.getString("title");
      r.body_ = data.getString("body");
      r.summary = data.getString("summary");
      r.category = data.getString("category");
      r.tags = data.getStrings("tags");

      auto result = useCase.updateArticle(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Knowledge base article updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteArticle(tenantId, id);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
