/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.tag_;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.manage.tags;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.tag;

class TagController : PlatformController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateTagRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.color = j.getString("color");
      r.parentTagId = j.getString("parentTagId");

      auto result = useCase.createTag(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Tag created");

        res.writeJsonBody(resp, 201);
      } else {
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
      auto tags = useCase.listTags(tenantId);
      auto arr = Json.emptyArray;
      foreach (t; tags)
        arr ~= serializeTag(t);
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

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto t = useCase.getTag(tenantId, id);
      if (t.isNull) {
        writeError(res, 404, "Tag not found");
        return;
      }
      res.writeJsonBody(serializeTag(*t), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateTagRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.color = j.getString("color");

      auto result = useCase.updateTag(r);
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
      auto result = useCase.deleteTag(tenantId, id);
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
