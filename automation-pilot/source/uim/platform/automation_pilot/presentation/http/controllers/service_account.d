/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.presentation.http.controllers.service_account;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ServiceAccountController : ManageController {
    private ManageServiceAccountsUseCase usecase;

    this(ManageServiceAccountsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/automation-pilot/service-accounts", &handleList);
        router.get("/api/v1/automation-pilot/service-accounts/*", &handleGet);
        router.post("/api/v1/automation-pilot/service-accounts", &handleCreate);
        router.put("/api/v1/automation-pilot/service-accounts/*", &handleUpdate);
        router.delete_("/api/v1/automation-pilot/service-accounts/*", &handleDelete);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto items = usecase.listServiceAccounts(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = ServiceAccountId(extractIdFromPath(path));

            auto e = usecase.getServiceAccount(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Service account not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            ServiceAccountDTO dto;
            dto.tenantId = tenantId;
            dto.serviceAccountId = ServiceAccountId(j.getString("id"));
            dto.tenantId = req.getTenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.clientId = j.getString("clientId");
            dto.permissions = j.getString("permissions");
            dto.expiresAt = j.getLong("expiresAt");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createServiceAccount(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Service account created");
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto j = req.json;

            ServiceAccountDTO dto;
            dto.tenantId = tenantId;
            dto.serviceAccountId = ServiceAccountId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.permissions = j.getString("permissions");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateServiceAccount(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Service account updated");

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
            auto path = req.requestURI.to!string;
            auto id = ServiceAccountId(extractIdFromPath(path));

            auto result = usecase.deleteServiceAccount(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Service account deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
