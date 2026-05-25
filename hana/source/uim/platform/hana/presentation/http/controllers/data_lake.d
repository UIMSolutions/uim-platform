/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.data_lake;
// import uim.platform.hana.application.usecases.manage.data_lakes;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class DataLakeController : ManageController {
  private ManageDataLakesUseCase usecase;

  this(ManageDataLakesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/dataLakes", &handleList);
    router.get("/api/v1/hana/dataLakes/*", &handleGet);
    router.post("/api/v1/hana/dataLakes", &handleCreate);
    router.put("/api/v1/hana/dataLakes/*", &handleUpdate);
    router.delete_("/api/v1/hana/dataLakes/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateDataLakeRequest r;
      r.tenantId = tenantId;
      r.instanceId = j.getString("instanceId");
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.computeNodes = j.getInteger("computeNodes", 1);
      r.storage = jsonKeyValuePairs(j, "storage");

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Data lake created");
          
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
      auto tenantId = req.getTenantId;
      auto lakes = usecase.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (d; lakes) {
        jarr ~= Json.emptyObject
        .set("id", d.id)
        .set("instanceId", d.instanceId)
        .set("name", d.name)
        .set("description", d.description)
        .set("status", d.status.to!string)
        .set("computeNodes", d.computeNodes)
        .set("createdAt", d.createdAt)
        .set("updatedAt", d.updatedAt);
      }

      auto resp = Json.emptyObject
      .set("count", Json(lakes.length))
      .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto d = usecase.getById(tenantId, id);
      if (d.isNull) {
        writeError(res, 404, "Data lake not found");
        return;
      }

      auto resp = Json.emptyObject
      .set("id", d.id)
      .set("instanceId", d.instanceId)
      .set("name", d.name)
      .set("description", d.description)
      .set("status", d.status.to!string)
      .set("computeNodes", d.computeNodes)
      .set("createdAt", d.createdAt)
      .set("updatedAt", d.updatedAt);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      

      auto j = req.json;
      UpdateDataLakeRequest r;
      r.tenantId = tenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.computeNodes = j.getInteger("computeNodes", 1);

      auto result = usecase.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
        .set("id", result.id)
        .set("message", "Data lake updated");

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
      auto tenantId = req.getTenantId;
      auto id = DataLakeId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.deleteDataLake(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
