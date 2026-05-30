/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.presentation.http.controllers.template_;
// import uim.platform.document_ai.application.usecases.manage.templates;
// import uim.platform.document_ai.application.dto;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.template_ : Template;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class TemplateController : ManageController {
  private ManageTemplatesUseCase usecase;

  this(ManageTemplatesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/templates", &handleCreate);
    router.get("/api/v1/templates", &handleList);
    router.get("/api/v1/templates/*", &handleGet);
    router.put("/api/v1/templates/*", &handleUpdate);
    router.delete_("/api/v1/templates/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateTemplateRequest r;
      r.tenantId = tenantId;
      r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
      r.schemaId = data.getString("schemaId");
      r.documentTypeId = data.getString("documentTypeId");
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.regions = jsonRegionArray(j, "regions");

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Template created");

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
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));
      auto templates = usecase.list(clientId);

      auto jarr = Json.emptyArray;
      foreach (t; templates) {
        jarr ~= templateToJson(t);
      }

      auto resp = Json.emptyObject
        .set("count", Json(templates.length))
        .set("resources", jarr)
        .set("message", "Template list retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

      auto t = usecase.getById(id, clientId);
      if (t.isNull) {
        writeError(res, 404, "Template not found");
        return;
      }

      res.writeJsonBody(templateToJson(t), 200);
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
      UpdateTemplateRequest r;
      r.tenantId = tenantId;
      r.clientId = ClientId(req.headers.get("X-Client-Id", ""));
      r.templateId = id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.status = data.getString("status");

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Template updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
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
      auto clientId = ClientId(req.headers.get("X-Client-Id", ""));

      auto result = usecase.deleteTemplate(TemplateId(id), clientId);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("message", "Template deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json templateToJson(Template t) {
    auto rArr = Json.emptyArray;
    foreach (r; t.regions) {
      rArr ~= Json.emptyObject
        .set("fieldName", r.fieldName)
        .set("page", r.page)
        .set("x", r.x)
        .set("y", r.y)
        .set("width", r.width)
        .set("height", r.height);
    }

    return Json.emptyObject
      .set("id", t.id)
      .set("schemaId", t.schemaId)
      .set("documentTypeId", t.documentTypeId)
      .set("name", t.name)
      .set("description", t.description)
      .set("status", t.status.to!string)
      .set("createdAt", t.createdAt)
      .set("updatedAt", t.updatedAt)
      .set("regions", rArr);
  }
}
