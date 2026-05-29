/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.backup;
// import uim.platform.hana.application.usecases.manage.backups;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class BackupController : ManageController {
  private ManageBackupsUseCase usecase;

  this(ManageBackupsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/backups", &handleList);
    router.get("/api/v1/hana/backups/*", &handleGet);
    router.post("/api/v1/hana/backups", &handleCreate);
    router.put("/api/v1/hana/backups/*", &handleUpdate);
    router.delete_("/api/v1/hana/backups/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateBackupRequest r;
      r.tenantId = tenantId;
      r.instanceId = data.getString("instanceId");
      r.id = precheck.id;
      r.name = data.getString("name");
      r.type = data.getString("type");
      r.destination = data.getString("destination");
      r.encrypted = data.getBoolean("encrypted");
      r.cronExpression = data.getString("cronExpression");
      r.retentionDays = data.getInteger("retentionDays", 30);

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Backup created");

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
      auto backups = usecase.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (b; backups) {
        jarr ~= Json.emptyObject
        .set("id", b.id)
        .set("instanceId", b.instanceId)
        .set("name", b.name)
        .set("status", b.status.to!string)
        .set("sizeBytes", b.sizeBytes)
        .set("encrypted", b.encrypted)
        .set("createdAt", b.createdAt);
      }

      auto response = Json.emptyObject;
      response["count"] = Json(backups.length);
      response["resources"] = jarr;

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto b = usecase.getById(tenantId, id);
      if (b.isNull) {
        writeError(res, 404, "Backup not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", b.id)
        .set("instanceId", b.instanceId)
        .set("name", b.name)
        .set("status", b.status.to!string)
        .set("sizeBytes", b.sizeBytes)
        .set("destination", b.destination)
        .set("encrypted", b.encrypted)
        .set("startedAt", b.startedAt)
        .set("completedAt", b.completedAt)
        .set("expiresAt", b.expiresAt)
        .set("createdAt", b.createdAt);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      

      auto data = precheck.data;
      UpdateBackupRequest r;
      r.tenantId = tenantId;
      r.id = precheck.id;
      r.name = data.getString("name");
      r.destination = data.getString("destination");
      r.cronExpression = data.getString("cronExpression");
      r.retentionDays = data.getInteger("retentionDays", 30);

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Backup updated");
          
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
      auto id = BackupId(precheck.id);
      auto result = usecase.deleteBackup(id);
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
