/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.content_cache;
// import uim.platform.html_repository.application.usecases.manage.content_cache;
// import uim.platform.html_repository.application.dto;
// import uim.platform.htmls;


import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class ContentCacheController : ManageHttpController {
  private ManageContentCacheUseCase usecase;

  this(ManageContentCacheUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/cache", &handleCreate);
    router.get("/api/v1/cache", &handleList);
    router.get("/api/v1/cache/*", &handleGet);
    router.delete_("/api/v1/cache/*", &handleDelete);
    router.post("/api/v1/cache/purge", &handlePurge);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateContentCacheRequest r;
      r.tenantId = tenantId;
      r.fileId = data.getString("fileId");
      r.filePath = data.getString("filePath");
      r.contentType = data.getString("contentType");
      r.data = data.getString("data");
      r.etag = data.getString("etag");
      r.ttlSeconds = data.getLong("ttlSeconds");

      auto result = usecase.create(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto items = usecase.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (e; items) {
        arr ~= Json.emptyObject
        .set("id", e.id)
        .set("fileId", e.fileId)
        .set("filePath", e.filePath)
        .set("status", e.status)
        .set("hitCount", e.hitCount);
      }

      auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      if (id.isNull) {
        writeError(res, 404, "Cache entry not found");
        return;
      }
      auto entry = usecase.getById(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Cache entry not found");
        return;
      }
      
      auto response = Json.emptyObject
      .set("id", entry.id)
      .set("fileId", entry.fileId)
      .set("filePath", entry.filePath)
      .set("contentType", entry.contentType)
      .set("data", entry.data)
      .set("etag", entry.etag)
      .set("ttlSeconds", entry.ttlSeconds)
      .set("status", entry.status)
      .set("hitCount", entry.hitCount)
      .set("createdAt", entry.createdAt)
      .set("expiresAt", entry.expiresAt);
      
      res.writeJsonBody(response, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      if (id.isNull) {
        writeError(res, 404, "Cache entry not found");
        return;
      }
      auto result = usecase.invalidate(tenantId, id);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handlePurge(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto result = usecase.purgeExpired(tenantId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
        .set("status", "purged");
        
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
