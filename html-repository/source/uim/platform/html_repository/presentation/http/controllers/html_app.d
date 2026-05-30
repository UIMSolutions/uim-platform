/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.html_app;

// import uim.platform.html_repository.application.usecases.manage.html_apps;
// import uim.platform.html_repository.application.dto;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class HtmlAppController : ManageController {
  private ManageHtmlAppsUseCase usecase;

  this(ManageHtmlAppsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/apps", &handleCreate);
    router.get("/api/v1/apps", &handleList);
    router.get("/api/v1/apps/*", &handleGet);
    router.put("/api/v1/apps/*", &handleUpdate);
    router.delete_("/api/v1/apps/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateHtmlAppRequest r;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.namespace_ = data.getString("namespace");
      r.description = data.getString("description");
      r.spaceId = data.getString("spaceId");
      r.serviceInstanceId = data.getString("serviceInstanceId");
      r.visibility = data.getString("visibility");
      r.createdBy = UserId(data.getString("createdBy"));

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
          .set("name", e.name)
          .set("namespace", e.namespace_)
          .set("visibility", e.visibility)
          .set("status", e.status);
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
        writeError(res, 404, "App not found");
        return;
      }
      auto entry = usecase.getById(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "App not found");
        return;
      }
      auto response = Json.emptyObject
        .set("id", entry.id)
        .set("name", entry.name)
        .set("namespace", entry.namespace_)
        .set("description", entry.description)
        .set("spaceId", entry.spaceId)
        .set("serviceInstanceId", entry.serviceInstanceId)
        .set("visibility", entry.visibility)
        .set("status", entry.status)
        .set("createdBy", entry.createdBy)
        .set("createdAt", entry.createdAt)
        .set("updatedBy", entry.updatedBy)
        .set("updatedAt", entry.updatedAt);

      res.writeJsonBody(response, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      if (id.isNull) {
        writeError(res, 404, "App not found");
        return;
      }
      UpdateHtmlAppRequest r;
      r.id = id;
      r.tenantId = tenantId;
      r.description = data.getString("description");
      r.visibility = data.getString("visibility");
      r.updatedBy = UserId(data.getString("updatedBy"));

      auto result = usecase.update(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", id)
          .set("message", "App updated");

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
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      if (id.isNull) {
        writeError(res, 404, "App not found");
        return;
      }
      auto result = usecase.deleteHtmlApp(tenantId, HtmlAppId(id));
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", id)
          .set("message", "App deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
