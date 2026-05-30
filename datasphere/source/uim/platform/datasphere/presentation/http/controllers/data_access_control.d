/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.data_access_control;
// import uim.platform.datasphere.application.usecases.manage.data_access_controls;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class DataAccessControlController : ManageController {
  private ManageDataAccessControlsUseCase usecase;

  this(ManageDataAccessControlsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/dataAccessControls", &handleList);
    router.get("/api/v1/datasphere/dataAccessControls/*", &handleGet);
    router.post("/api/v1/datasphere/dataAccessControls", &handleCreate);
    router.delete_("/api/v1/datasphere/dataAccessControls/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateDataAccessControlRequest r;
      r.tenantId = tenantId;
      r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.criteriaType = data.getString("criteriaType");
      r.targetViewIds = j.getArray("targetViewIds").map!(v => ViewId(v.to!string)).array.toJson;
      r.assignedUserIds = j.getArray("assignedUserIds")
        .map!(v => UserId(v.to!string)).array.toJson;

      auto result = usecase.createDataAccessControl(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Data access control created");

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
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      auto controls = usecase.listDataAccessControls(tenantId, spaceId);

      auto jarr = Json.emptyArray;
      foreach (dac; controls) {
        jarr ~= Json.emptyObject
          .set("id", dac.id)
          .set("name", dac.name)
          .set("description", dac.description)
          .set("isEnabled", dac.isEnabled)
          .set("createdAt", dac.createdAt);
      }

      auto resp = Json.emptyObject
        .set("count", controls.length)
        .set("resources", jarr)
        .set("message", "Data access controls retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = DataAccessControlId(precheck.id);
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto dac = usecase.getDataAccessControl(tenantId, spaceId, id);
      if (dac.isNull) {
        writeError(res, 404, "Data access control not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", dac.id)
        .set("name", dac.name)
        .set("description", dac.description)
        .set("isEnabled", dac.isEnabled)
        .set("targetViewIds", dac.targetViewIds.map!(v => v.toJson)
            .array.toJson)
        .set("assignedUserIds", dac.assignedUserIds.map!(v => v.toJson)
            .array.toJson)
        .set("createdAt", dac.createdAt)
        .set("updatedAt", dac.updatedAt)
        .set("message", "Data access control retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = DataAccessControlId(precheck.id);
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto result = usecase.deleteDataAccessControl(tenantId, spaceId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("message", "Data access control deleted"); 

        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
