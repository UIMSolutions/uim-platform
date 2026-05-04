/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.dns_record;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class DnsRecordController : PlatformController {
    private ManageDnsRecordsUseCase uc;

    this(ManageDnsRecordsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/custom-domain/dns-records", &handleList);
        router.get("/api/v1/custom-domain/dns-records/*", &handleGet);
        router.post("/api/v1/custom-domain/dns-records", &handleCreate);
        router.put("/api/v1/custom-domain/dns-records/*", &handleUpdate);
        router.delete_("/api/v1/custom-domain/dns-records/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateDnsRecordRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.customDomainId = j.getString("customDomainId");
            r.recordType = j.getString("recordType");
            r.hostname = j.getString("hostname");
            r.value = j.getString("value");
            r.ttl = j.getInteger("ttl");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "DNS record created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;
            auto records = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (r; records) {
                jarr ~= Json.emptyObject
                .set("id", r.id)
                .set("customDomainId", r.customDomainId)
                .set("recordType", r.recordType.to!string)
                .set("hostname", r.hostname)
                .set("value", r.value)
                .set("ttl", r.ttl)
                .set("validationStatus", r.validationStatus.to!string)
                .set("createdBy", r.createdBy)
                .set("createdAt", r.createdAt);
            }

            auto resp = Json.emptyObject
                .set("count", Json(records.length))
                .set("resources", jarr)
                .set("message", "DNS records retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto r = uc.getById(id);
            if (r.isNull) {
                writeError(res, 404, "DNS record not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", Json(r.id))
                .set("customDomainId", Json(r.customDomainId))
                .set("recordType", Json(r.recordType.to!string))
                .set("hostname", Json(r.hostname))
                .set("value", Json(r.value))
                .set("ttl", Json(r.ttl))
                .set("validationStatus", Json(r.validationStatus.to!string))
                .set("lastValidatedAt", Json(r.lastValidatedAt))
                .set("createdBy", Json(r.createdBy))
                .set("createdAt", Json(r.createdAt))
                .set("updatedAt", Json(r.updatedAt));

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateDnsRecordRequest r;
            r.tenantId = req.getTenantId;
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.value = j.getString("value");
            r.ttl = j.getInteger("ttl");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "DNS record updated");

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

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.removeById(id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "DNS record deleted");
                    
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
