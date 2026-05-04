/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.buildpack;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.foundry.application.usecases.manage.buildpacks;
// import uim.platform.foundry.application.dto;
// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.buildpack;
import uim.platform.foundry;

class BuildpackController : PlatformController {
  private ManageBuildpacksUseCase useCase;

  this(ManageBuildpacksUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/buildpacks", &handleCreate);
    router.get("/api/v1/buildpacks", &handleList);
    router.get("/api/v1/buildpacks/*", &handleGetById);
    router.put("/api/v1/buildpacks/*", &handleUpdate);
    router.delete_("/api/v1/buildpacks/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateBuildpackRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.type_ = parseBuildpackType(j.getString("type"));
      r.position = j.getInteger("position");
      r.stack = j.getString("stack");
      r.filename = j.getString("filename");
      r.createdBy = UserId(j.getString("createdBy"));

      auto result = useCase.createBuildpack(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = useCase.listBuildpacks(tenantId);

      auto arr = items.map!(bp => bp.toJson()).array;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto buildpackId = BuildpackId(extractIdFromPath(req.requestURI));
      TenantId tenantId = req.getTenantId;
      auto bp = useCase.getBuildpack(tenantId, buildpackId);
      if (bp.isNull) {
        writeError(res, 404, "Buildpack not found");
        return;
      }
      res.writeJsonBody(bp.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto buildpackId = BuildpackId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      auto r = UpdateBuildpackRequest();
      r.id = buildpackId;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.position = j.getInteger("position");
      r.stack = j.getString("stack");
      r.filename = j.getString("filename");
      r.enabled = j.getBoolean("enabled", true);
      r.locked = j.getBoolean("locked");

      auto result = useCase.updateBuildpack(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Buildpack updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto buildpackId = BuildpackId(extractIdFromPath(req.requestURI));
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteBuildpack(tenantId, buildpackId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
