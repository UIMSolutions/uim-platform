/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.buildpack;






// import uim.platform.foundry.application.usecases.manage.buildpacks;
// import uim.platform.foundry.application.dto;
// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.buildpack;
import uim.platform.foundry;

class BuildpackController : ManageController {
  private ManageBuildpacksUseCase useCase;

  this(ManageBuildpacksUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/buildpacks", &handleCreate);
    router.get("/api/v1/buildpacks", &handleList);
    router.get("/api/v1/buildpacks/*", &handleGet);
    router.put("/api/v1/buildpacks/*", &handleUpdate);
    router.delete_("/api/v1/buildpacks/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateBuildpackRequest();
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.type_ = parseBuildpackType(data.getString("type"));
      r.position = j.getInteger("position");
      r.stack = data.getString("stack");
      r.filename = data.getString("filename");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = useCase.createBuildpack(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto items = useCase.listBuildpacks(tenantId);

      auto arr = items.map!(bp => bp.toJson()).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto buildpackId = BuildpackId(precheck.id);
      auto tenantId = precheck.tenantId;
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

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto buildpackId = BuildpackId(precheck.id);
      auto data = precheck.data;
      auto r = UpdateBuildpackRequest();
      r.id = buildpackId;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.position = j.getInteger("position");
      r.stack = data.getString("stack");
      r.filename = data.getString("filename");
      r.enabled = j.getBoolean("enabled", true);
      r.locked = j.getBoolean("locked");

      auto result = useCase.updateBuildpack(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Buildpack updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto buildpackId = BuildpackId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteBuildpack(tenantId, buildpackId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
