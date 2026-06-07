/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.dns_record;

import uim.platform.custom_domain;

// mixin(ShowModule!());

@safe:

class DnsRecordController : ManageHttpController {
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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

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

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("DNS record created successfully", "Created", 201, responseData);
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

        auto responseData = Json.emptyObject
            .set("count", records.length)
            .set("resources", jarr);
        return successResponse("DNS record list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DnsRecordId(precheck.id);

        auto record = usecase.getDnsRecord(tenantId, id);
        if (record.isNull)
            return errorResponse("DNS record not found", 404);

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

        return successResponse("DNS record retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        UpdateDnsRecordRequest r;
        r.tenantId = tenantId;
        r.dnsRecordId = DnsRecordId(precheck.id);
        r.value = data.getString("value");
        r.ttl = data.getInteger("ttl");

        auto result = usecase.updateDnsRecord(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("DNS record updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DnsRecordId(precheck.id);

        auto result = usecase.deleteDnsRecord(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("DNS record deleted successfully", "Deleted", 200, responseData);
    }
}
