/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.view_;
// import uim.platform.datasphere.application.usecases.manage.views;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:

class ViewController : ManageController {
  private ManageViewsUseCase usecase;

  this(ManageViewsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/datasphere/views", &handleList);
    router.get("/api/v1/datasphere/views/*", &handleGet);
    router.post("/api/v1/datasphere/views", &handleCreate);
    router.put("/api/v1/datasphere/views/*", &handleUpdate);
    router.delete_("/api/v1/datasphere/views/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateViewRequest r;
      r.tenantId = tenantId;
      r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.businessName = data.getString("businessName");
      r.semantic = data.getString("semantic");
      r.sqlExpression = data.getString("sqlExpression");
      r.isExposed = data.getBoolean("isExposed", false);

      auto now = Clock.currTime();
      // r.createdAt = now;
      // r.updatedAt = now;

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "View created");

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
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      auto views = usecase.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (v; views) {
        jarr ~= Json.emptyObject
          .set("id", v.id)
          .set("name", v.name)
          .set("description", v.description)
          .set("businessName", v.businessName)
          .set("isExposed", v.isExposed)
          .set("isPersisted", v.isPersisted)
          .set("rowCount", v.rowCount)
          .set("createdAt", v.createdAt);
      }

      auto resp = Json.emptyObject
            .set("count", Json(views.length))
            .set("resources", jarr)
            .set("message", "Views retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = ViewId(precheck.id);
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto v = usecase.getById(spaceId, id);
      if (v.isNull) {
        writeError(res, 404, "View not found");
        return;
      }

      auto resp = Json.emptyObject
            .set("id", v.id)
            .set("name", v.name)
            .set("description", v.description)
            .set("businessName", v.businessName)
            .set("sqlExpression", v.sqlExpression)
            .set("isExposed", v.isExposed)
            .set("isPersisted", v.isPersisted)
            .set("rowCount", v.rowCount)
            .set("createdAt", v.createdAt)
            .set("updatedAt", v.updatedAt)
            .set("message", "View retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      

      auto data = precheck.data;
      UpdateViewRequest r;
      r.tenantId = tenantId;
      r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      r.viewId = ViewId(precheck.id);
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.businessName = data.getString("businessName");
      r.sqlExpression = data.getString("sqlExpression");
      r.isExposed = data.getBoolean("isExposed", false);
      r.isPersisted = data.getBoolean("isPersisted", false);

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "View updated");
            
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

      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      auto id = ViewId(precheck.id);

      auto result = usecase.deleteView(spaceId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
