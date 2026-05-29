/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.space;






// import uim.platform.foundry.application.usecases.manage.spaces;
// import uim.platform.foundry.application.dto;
// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.space;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:

class SpaceController : ManageController {
  private ManageSpacesUseCase useCase;

  this(ManageSpacesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/spaces", &handleCreate);
    router.get("/api/v1/spaces", &handleList);
    router.get("/api/v1/spaces/*", &handleGet);
    router.put("/api/v1/spaces/*", &handleUpdate);
    router.delete_("/api/v1/spaces/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateSpaceRequest();
      r.tenantId = tenantId;
      r.orgId = OrgId(data.getString("orgId"));
      r.name = data.getString("name");
      r.allowSsh = data.getBoolean("allowSsh", true);
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = useCase.createSpace(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Space created");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
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

      auto spaces = useCase.listSpaces(tenantId);
      auto arr = spaces.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(spaces.length))
        .set("message", "Spaces retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = SpaceId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto space = useCase.getSpace(tenantId, id);
      if (space.isNull) {
        writeError(res, 404, "Space not found");
        return;
      }
      res.writeJsonBody(space.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = SpaceId(precheck.id);
      auto data = precheck.data;
      auto r = UpdateSpaceRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.allowSsh = data.getBoolean("allowSsh", true);

      auto result = useCase.updateSpace(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Space updated");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = SpaceId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteSpace(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Space deleted");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
