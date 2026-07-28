/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.personal_data_record;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class PersonalDataRecordController : ManageHttpController {
    private ManagePersonalDataRecordsUseCase usecase;

    this(ManagePersonalDataRecordsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/personal-data/records", &handleList);
        router.get("/api/v1/personal-data/records/*", &handleGet);
        router.post("/api/v1/personal-data/records", &handleCreate);
        router.delete_("/api/v1/personal-data/records/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreatePersonalDataRecordRequest r;
        r.tenantId = tenantId;
        r.id = precheck.id;
        r.dataSubjectId = data.getString("dataSubjectId");
        r.applicationId = data.getString("applicationId");
        // TODO: r.dataCategory = data.getString("dataCategory");
        r.sensitivity = data.getString("sensitivity");
        r.fieldName = data.getString("fieldName");
        r.fieldValue = data.getString("fieldValue");
        r.purposeId = data.getString("purposeId");
        r.legalBasis = data.getString("legalBasis");
        r.retentionRuleId = data.getString("retentionRuleId");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createPersonalDataRecord(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id);
        return successResponse("Personal data record created successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        auto dataSubjectId = DataSubjectId(data.getString("dataSubjectId"));
        auto applicationId = RegisteredApplicationId(data.getString("applicationId"));

        PersonalDataRecord[] records;
        if (!dataSubjectId.isEmpty && !applicationId.isEmpty) {
            records = usecase.listPersonalDataRecords(tenantId, dataSubjectId, applicationId);
        } else if (!dataSubjectId.isEmpty) {
            records = usecase.listPersonalDataRecords(tenantId, dataSubjectId);
        } else if (!applicationId.isEmpty) {
            records = usecase.listPersonalDataRecords(tenantId, applicationId);
        } else {
            records = usecase.listPersonalDataRecords(tenantId);
        }

        auto jarr = records.map!(r => r.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", records.length)
            .set("resources", jarr);

        return successResponse("Personal data records retrieved successfully", "Retrieved", 200, resp);
    }

    override Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = PersonalDataRecordId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid personal data record ID", 400);

        auto r = usecase.getPersonalDataRecord(tenantId, id);
        if (r.isNull)
            return errorResponse("Personal data record not found", 404);

        return successResponse("Personal data record retrieved successfully", "Retrieved", 200, r
                .toJson);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = PersonalDataRecordId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid personal data record ID", 400);

        auto result = usecase.deletePersonalDataRecord(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Personal data record deleted successfully", "Deleted", 200, responseData);
    }
}
