/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.personal_data_record;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class PersonalDataRecordController : SAPController {
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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = jsonStr(j, "id");
            r.dataSubjectId = jsonStr(j, "dataSubjectId");
            r.applicationId = jsonStr(j, "applicationId");
            r.dataCategory = jsonStr(j, "dataCategory");
            r.sensitivity = jsonStr(j, "sensitivity");
            r.fieldName = jsonStr(j, "fieldName");
            r.fieldValue = jsonStr(j, "fieldValue");
            r.purposeId = jsonStr(j, "purposeId");
            r.legalBasis = jsonStr(j, "legalBasis");
            r.retentionRuleId = jsonStr(j, "retentionRuleId");
            r.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Personal data record created");
                res.writeJsonBody(resp, 201);
            } ) {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
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
            } ) {
                records = uc.list(tenantId);
            }

            auto jarr = Json.emptyArray;
            foreach (ref r; records) {
                jarr ~= recordToJson(r);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) records.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto r = uc.get_(id);
            if (r.id.length == 0) {
                writeError(res, 404, "Personal data record not found");
                return;
            }
            res.writeJsonBody(recordToJson(r), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Personal data record deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json recordToJson(ref PersonalDataRecord r) {
        auto j = Json.emptyObject;
        j["id"] = Json(r.id);
        j["dataSubjectId"] = Json(r.dataSubjectId);
        j["applicationId"] = Json(r.applicationId);
        j["dataCategory"] = Json(r.dataCategory.to!string);
        j["sensitivity"] = Json(r.sensitivity.to!string);
        j["fieldName"] = Json(r.fieldName);
        j["fieldValue"] = Json(r.fieldValue);
        j["purposeId"] = Json(r.purposeId);
        j["legalBasis"] = Json(r.legalBasis.to!string);
        j["retentionRuleId"] = Json(r.retentionRuleId);
        j["isAnonymized"] = Json(r.isAnonymized);
        j["createdBy"] = Json(r.createdBy);
        j["createdAt"] = Json(r.createdAt);
        return j;
    }
}
