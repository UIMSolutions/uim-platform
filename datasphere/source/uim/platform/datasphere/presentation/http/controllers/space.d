/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.space;
// import uim.platform.datasphere.application.usecases.manage.spaces;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class SpaceController : ManageController {
  private ManageSpacesUseCase usecase;

  this(ManageSpacesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/spaces", &handleList);
    router.get("/api/v1/datasphere/spaces/*", &handleGet);
    router.post("/api/v1/datasphere/spaces", &handleCreate);
    router.put("/api/v1/datasphere/spaces/*", &handleUpdate);
    router.delete_("/api/v1/datasphere/spaces/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateSpaceRequest r;
      r.tenantId = tenantId;
      r.spaceId = SpaceId(precheck.id);
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.businessName = data.getString("businessName");
      r.priority = data.getInteger("priority", 0);

      auto result = usecase.createSpace(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Space created");

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
      auto tenantId = precheck.tenantId;
      auto spaces = usecase.listSpaces(tenantId);

      auto jarr = Json.emptyArray;
      foreach (s; spaces) {
        jarr ~= Json.emptyObject
          .set("id", s.id)
          .set("name", s.name)
          .set("description", s.description)
          .set("businessName", s.businessName)
          .set("priority", s.priority)
          .set("createdAt", s.createdAt)
          .set("updatedAt", s.updatedAt);
      }

      auto resp = Json.emptyObject
        .set("count", Json(spaces.length))
        .set("resources", jarr)
        .set("message", "Spaces retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = Spaceprecheck.id);
      auto s = usecase.getSpace(tenantId, id);
      if (s.isNull) {
        writeError(res, 404, "Space not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", s.id)
        .set("name", s.name)
        .set("description", s.description)
        .set("businessName", s.businessName)
        .set("priority", s.priority)
        .set("enableAuditLog", s.enableAuditLog)
        .set("createdAt", s.createdAt)
        .set("updatedAt", s.updatedAt)
        .set("message", "Space retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      UpdateSpaceRequest r;
      r.tenantId = tenantId;
      r.spaceId = Spaceprecheck.id);
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.businessName = data.getString("businessName");
      r.priority = data.getInteger("priority", 0);

      auto result = usecase.updateSpace(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Space updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = Spaceprecheck.id);

      auto result = usecase.deleteSpace(tenantId, id);
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
