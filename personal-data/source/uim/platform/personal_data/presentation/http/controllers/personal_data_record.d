/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.personal_data_record;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class PersonalDataRecordController : PlatformController {
    private ManagePersonalDataRecordsUseCase uc;

    this(ManagePersonalDataRecordsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/personal-data/records", &handleList);
        router.get("/api/v1/personal-data/records/*", &handleGet);
        router.post("/api/v1/personal-data/records", &handleCreate);
        router.delete_("/api/v1/personal-data/records/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreatePersonalDataRecordRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.dataSubjectId = j.getString("dataSubjectId");
            r.applicationId = j.getString("applicationId");
            r.dataCategory = j.getString("dataCategory");
            r.sensitivity = j.getString("sensitivity");
            r.fieldName = j.getString("fieldName");
            r.fieldValue = j.getString("fieldValue");
            r.purposeId = j.getString("purposeId");
            r.legalBasis = j.getString("legalBasis");
            r.retentionRuleId = j.getString("retentionRuleId");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Personal data record created");

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
            auto params = req.queryParams();
            auto dataSubjectId = params.get("dataSubjectId", "");
            auto applicationId = params.get("applicationId", "");

            PersonalDataRecord[] records;
            if (dataSubjectId.length > 0 && applicationId.length > 0) {
                records = uc.listByDataSubjectAndApplication(dataSubjectId, applicationId);
            } else if (dataSubjectId.length > 0) {
                records = uc.listByDataSubject(dataSubjectId);
            } else if (applicationId.length > 0) {
                records = uc.listByApplication(applicationId);
            } else {
                records = uc.list(tenantId);
            }

            auto jarr = records.map!(r => toJson(r)).array;

            auto resp = Json.emptyObject
                .set("count", records.length)
                .set("resources", jarr)
                .set("message", "Personal data records retrieved successfully");

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
                writeError(res, 404, "Personal data record not found");
                return;
            }
            res.writeJsonBody(toJson(r), 200);
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
                  .set("message", "Personal data record deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
