/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.tag_;



// import uim.platform.workzone.application.usecases.manage.manage.tags;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.tag;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class TagController : ManageController {
  private ManageTagsUseCase useCase;

  this(ManageTagsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/tags", &handleCreate);
    router.get("/api/v1/tags", &handleList);
    router.get("/api/v1/tags/*", &handleGet);
    router.put("/api/v1/tags/*", &handleUpdate);
    router.delete_("/api/v1/tags/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateTagRequest();
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.color = data.getString("color");
      r.parentTagId = data.getString("parentTagId");

      auto result = useCase.createTag(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Tag created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto tags = useCase.listTags(tenantId);
      auto arr = tags.map!(t => t.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", tags.length)
        .set("message", "Tags retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto t = useCase.getTag(tenantId, id);
      if (t.isNull) {
        writeError(res, 404, "Tag not found");
        return;
      }
      res.writeJsonBody(t.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = UpdateTagRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.color = data.getString("color");

      auto result = useCase.updateTag(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Tag updated successfully");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteTag(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("message", "Tag deleted successfully");
        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.message);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
