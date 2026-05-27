/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.dns_record;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class DnsRecordController : ManageController {
    private ManageDnsRecordsUseCase usecase;

    this(ManageDnsRecordsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/custom-domain/dns-records", &handleList);
        router.get("/api/v1/custom-domain/dns-records/*", &handleGet);
        router.post("/api/v1/custom-domain/dns-records", &handleCreate);
        router.put("/api/v1/custom-domain/dns-records/*", &handleUpdate);
        router.delete_("/api/v1/custom-domain/dns-records/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            CreateDnsRecordRequest r;
            r.tenantId = tenantId;
            r.dnsRecordId = DnsRecordId(precheck.id);
            r.customDomainId = CustomDomainId(data.getString("customDomainId"));
            r.recordType = data.getString("recordType");
            r.hostname = data.getString("hostname");
            r.value = data.getString("value");
            r.ttl = data.getInteger("ttl");
            r.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createDnsRecord(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "DNS record created");

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


            auto records = usecase.listDnsRecords(tenantId);
            auto jarr = Json.emptyArray;
            foreach (record; records) {
                jarr ~= Json.emptyObject
                .set("id", record.id)
                .set("customDomainId", record.customDomainId)
                .set("recordType", record.recordType.to!string)
                .set("hostname", record.hostname)
                .set("value", record.value)
                .set("ttl", record.ttl)
                .set("validationStatus", record.validationStatus.to!string)
                .set("createdBy", record.createdBy)
                .set("createdAt", record.createdAt);
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

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = DnsRecordprecheck.id);
            
            auto record = usecase.getDnsRecord(tenantId, id);
            if (record.isNull) {
                writeError(res, 404, "DNS record not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", record.id)
                .set("customDomainId", record.customDomainId)
                .set("recordType", record.recordType.to!string)
                .set("hostname", record.hostname)
                .set("value", record.value)
                .set("ttl", record.ttl)
                .set("validationStatus", record.validationStatus.to!string)
                .set("lastValidatedAt", record.lastValidatedAt)
                .set("createdBy", record.createdBy)
                .set("createdAt", record.createdAt)
                .set("updatedAt", record.updatedAt);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            UpdateDnsRecordRequest r;
            r.tenantId = tenantId;
            r.dnsRecordId = DnsRecordprecheck.id) ;
            r.value = data.getString("value");
            r.ttl = data.getInteger("ttl");

            auto result = usecase.updateDnsRecord(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "DNS record updated");

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
            auto id = DnsRecordprecheck.id);

            auto result = usecase.deleteDnsRecord(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "DNS record deleted");
                    
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
