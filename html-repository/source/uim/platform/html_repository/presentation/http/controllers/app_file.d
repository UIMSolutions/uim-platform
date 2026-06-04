/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.app_file;
// import uim.platform.html_repository.application.usecases.manage.app_files;
// import uim.platform.html_repository.application.dto;
// import uim.platform.htmls;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class AppFileController : ManageHttpController {
  private ManageAppFilesUseCase usecase;

  this(ManageAppFilesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/files", &handleCreate);
    router.get("/api/v1/files", &handleList);
    router.get("/api/v1/files/*", &handleGet);
    router.put("/api/v1/files/*", &handleUpdate);
    router.delete_("/api/v1/files/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      UploadAppFileRequest r;
      r.tenantId = tenantId;
      r.versionId = data.getString("versionId");
      r.filePath = data.getString("filePath");
      r.contentType = data.getString("contentType");
      r.data = data.getString("data");
      r.encoding = data.getString("encoding");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = usecase.uploadAppFile(r);
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
      auto versionId = getString(req.json, "versionId");
      if (versionId.isEmpty)
        versionId = req.headers.get("X-Version-Id", "");

      auto items = usecase.listAppFiles(tenantId, versionId);
      auto arr = Json.emptyArray;
      foreach (e; items) {
        auto obj = Json.emptyObject
          .set("id", e.id)
          .set("filePath", e.filePath)
          .set("contentType", e.contentType)
          .set("category", e.category)
          .set("sizeBytes", e.sizeBytes);

        arr ~= obj;
      }

      auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = AppFileId(precheck.id);
      auto tenantId = precheck.tenantId;
      if (isNull) {
        writeError(res, 404, "File not found");
        return;
      }
      auto entry = usecase.getAppFile(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "File not found");
        return;
      }
      auto response = Json.emptyObject
        .set("id", entry.id)
        .set("versionId", entry.versionId)
        .set("filePath", entry.filePath)
        .set("contentType", entry.contentType)
        .set("category", entry.category)
        .set("sizeBytes", entry.sizeBytes)
        .set("data", entry.data)
        .set("encoding", entry.encoding)
        .set("createdBy", entry.createdBy)
        .set("createdAt", entry.createdAt)
        .set("updatedAt", entry.updatedAt);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = AppFileId(precheck.id);

      auto tenantId = precheck.tenantId;
      if (id.isNull) {
        writeError(res, 404, "File not found");
        return;
      }
      UpdateAppFileRequest r;
      r.contentType = data.getString("contentType");
      r.data = data.getString("data");
      r.encoding = data.getString("encoding");

      auto result = usecase.updateAppFile(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", id)
          .set("message", "File updated");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = AppFileId(precheck.id);
      if (id.isNull) {
        writeError(res, 404, "File not found");
        return;
      }
      auto result = usecase.deleteAppFile(tenantId, id);
      if (result.isSuccess())
        res.writeBody("", 204);
      else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
