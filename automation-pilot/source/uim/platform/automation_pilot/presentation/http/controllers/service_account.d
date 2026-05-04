/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.service_account;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ServiceAccountController : PlatformController {
    private ManageServiceAccountsUseCase serviceAccounts;

    this(ManageServiceAccountsUseCase serviceAccounts) {
        this.serviceAccounts = serviceAccounts;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/automation-pilot/service-accounts", &handleList);
        router.get("/api/v1/automation-pilot/service-accounts/*", &handleGet);
        router.post("/api/v1/automation-pilot/service-accounts", &handleCreate);
        router.put("/api/v1/automation-pilot/service-accounts/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/service-accounts/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = serviceAccounts.list();
            auto jarr = items.map!(e => e.serviceAccountToJson()).array;

            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = serviceAccounts.getById(ServiceAccountId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Service account not found"); return; }
            res.writeJsonBody(e.serviceAccountToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            ServiceAccountDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.clientId = j.getString("clientId");
            dto.permissions = j.getString("permissions");
            dto.expiresAt = j.getString("expiresAt");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = serviceAccounts.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Service account created");
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            ServiceAccountDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.permissions = j.getString("permissions");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = serviceAccounts.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Service account updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = serviceAccounts.remove(ServiceAccountId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Service account deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
