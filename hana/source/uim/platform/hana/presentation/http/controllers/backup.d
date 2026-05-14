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

class BackupController : PlatformController {
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

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateBackupRequest r;
      r.tenantId = tenantId;
      r.instanceId = j.getString("instanceId");
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.type = j.getString("type");
      r.destination = j.getString("destination");
      r.encrypted = j.getBoolean("encrypted");
      r.cronExpression = j.getString("cronExpression");
      r.retentionDays = j.getInteger("retentionDays", 30);

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Backup created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
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

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI.to!string);
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

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      

      auto j = req.json;
      UpdateBackupRequest r;
      r.tenantId = tenantId;
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = j.getString("name");
      r.destination = j.getString("destination");
      r.cronExpression = j.getString("cronExpression");
      r.retentionDays = j.getInteger("retentionDays", 30);

      auto result = usecase.update(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Backup updated");
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = BackupId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.deleteBackup(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
