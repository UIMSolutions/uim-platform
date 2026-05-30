/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.hdi_container;
// import uim.platform.hana.application.usecases.manage.hdi_containers;
// import uim.platform.hana.application.dto;
import uim.platform.hana;

mixin(ShowModule!());

@safe:

class HDIContainerController : ManageController {
  private ManageHDIContainersUseCase usecase;

  this(ManageHDIContainersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/hana/hdiContainers", &handleList);
    router.get("/api/v1/hana/hdiContainers/*", &handleGet);
    router.post("/api/v1/hana/hdiContainers", &handleCreate);
    router.put("/api/v1/hana/hdiContainers/*", &handleUpdate);
    router.delete_("/api/v1/hana/hdiContainers/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateHDIContainerRequest r;
      r.tenantId = tenantId;
      r.instanceId = data.getString("instanceId");
      r.id = precheck.id;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.appUser = data.getString("appUser");
      r.grantedSchemas = data.getStrings("grantedSchemas");

      auto result = usecase.createHDIContainer(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "HDI Container created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto containers = usecase.listHDIContainers(tenantId);

      auto jarr = Json.emptyArray;
      foreach (c; containers) {
        jarr ~= Json.emptyObject
          .set("id", c.id)
          .set("instanceId", c.instanceId)
          .set("name", c.name)
          .set("status", c.status.to!string)
          .set("artifactCount", c.artifactCount)
          .set("sizeBytes", c.sizeBytes)
          .set("createdAt", c.createdAt);
      }

      auto resp = Json.emptyObject
        .set("count", Json(containers.length))
        .set("resources", list);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto c = usecase.getById(tenantId, id);
      if (c.isNull) {
        writeError(res, 404, "HDI Container not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", c.id)
        .set("instanceId", c.instanceId)
        .set("name", c.name)
        .set("description", c.description)
        .set("status", c.status.to!string)
        .set("schemaName", c.schemaName)
        .set("appUser", c.appUser)
        .set("artifactCount", c.artifactCount)
        .set("sizeBytes", c.sizeBytes)
        .set("grantedSchemas", stringsToJsonArray(c.grantedSchemas))
        .set("createdAt", c.createdAt)
        .set("updatedAt", c.updatedAt);

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
      UpdateHDIContainerRequest r;
      r.tenantId = tenantId;
      r.id = HDIContainerId(precheck.id);
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.grantedSchemas = data.getStrings("grantedSchemas");

      auto result = usecase.updateHDIContainer(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "HDI Container updated");

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
      auto id = HDIContainerId(precheck.id);

      auto result = usecase.deleteHDIContainer(tenantId, id);
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
