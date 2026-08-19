/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.data_subject;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class DataSubjectController : ManageHttpController {
    private ManageDataSubjectsUseCase usecase;

    this(ManageDataSubjectsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/personal-data/subjects", &handleList);
        router.get("/api/v1/personal-data/subjects/search", &handleSearch);
        router.get("/api/v1/personal-data/subjects/*", &handleGet);
        router.post("/api/v1/personal-data/subjects", &handleCreate);
        router.put("/api/v1/personal-data/subjects/*", &handleUpdate);
        router.post("/api/v1/personal-data/subjects/*/block", &handleBlock);
        router.post("/api/v1/personal-data/subjects/*/erase", &handleErase);
        router.delete_("/api/v1/personal-data/subjects/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateDataSubjectRequest r;
        r.tenantId = tenantId;
        // TODO: r.id = precheck.id;
        r.subjectType = data.getString("subjectType");
        r.firstName = data.getString("firstName");
        r.lastName = data.getString("lastName");
        r.email = data.getString("email");
        // TODO: r.phone = data.getString("phone");
        r.dateOfBirth = data.getString("dateOfBirth");
        r.organizationName = data.getString("organizationName");
        r.organizationId = data.getString("organizationId");
        r.externalId = data.getString("externalId");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDataSubject(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Data subject created successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto subjects = usecase.listDataSubjects(tenantId).map!(s => s.toJson).array.toJson;
        auto resp = Json.emptyObject
            .set("count", subjects.length)
            .set("resources", subjects);

        return successResponse("Data subjects retrieved successfully", "Retrieved", 200, resp);
    }

    protected Json searchHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        auto firstName = data.getString("firstName", "");
        auto lastName = data.getString("lastName", "");
        auto email = data.getString("email", "");

        DataSubject[] results;
        if (!email.isEmpty) {
            auto s = usecase.findDataSubjectByEmail(tenantId, email);
            if (!s.isNull)
                results ~= s;
        } else {
            results = usecase.searchDataSubjectsByName(tenantId, firstName, lastName);
        }

        auto jarr = results.map!(s => s.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", results.length)
            .set("resources", jarr);

        return successResponse("Data subjects retrieved successfully", "Retrieved", 200, resp);
    }

    mixin(HandleTemplate!("handleSearch", "searchHandler"));

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        if (path.length > 6 && path[$ - 6 .. $] == "/block")
            return successResponse("Data subject blocked successfully", "Blocked", 200, Json.emptyObject); // TODO:

        if (path.length > 6 && path[$ - 6 .. $] == "/erase")
            return successResponse("Data subject erased successfully", "Erased", 200, Json.emptyObject);// TODO:

        auto id = DataSubjectId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data subject ID", 400);

        auto subject = usecase.getDataSubject(tenantId, id);
        if (subject.isNull)
            return errorResponse("Data subject not found", 404);

        return successResponse("Data subject retrieved successfully", "Retrieved", 200, subject
                .toJson);

    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        UpdateDataSubjectRequest request;
        request.tenantId = tenantId;
        request.requestId = DataSubjectRequestId(precheck.id);
        request.firstName = data.getString("firstName");
        request.lastName = data.getString("lastName");
        request.email = data.getString("email");
        request.phoneNumber = data.getString("phone");
        // TODO: request.dateOfBirth = data.getString("dateOfBirth");
        request.organizationName = data.getString("organizationName");
        request.organizationId = data.getString("organizationId");
        request.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateDataSubject(request);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Data subject updated successfully", 200, resp);
    }

    protected Json blockHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto stripped = path[0 .. $ - 6]; // remove "/block"
        auto id = DataSubjectId(extractId(stripped));
        if (id.isNull)
            return errorResponse("Invalid data subject ID", 400);

        auto result = usecase.blockDataSubject(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data subject blocked");

        return successResponse("Data subject blocked successfully", 200, resp);
    }

    mixin(HandleTemplate!("handleBlock", "blockHandler"));

    protected Json eraseHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto stripped = path[0 .. $ - 6]; // remove "/erase"
        auto id = DataSubjectId(extractId(stripped));
        if (id.isNull)
            return errorResponse("Invalid data subject ID", 400);

        auto result = usecase.eraseDataSubject(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data subject erased (anonymized)");

        return successResponse("Data subject erased successfully", 200, resp);
    }

    mixin(HandleTemplate!("handleErase", "eraseHandler"));

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataSubjectId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data subject ID", 400);

        auto result = usecase.deleteDataSubject(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data subject deleted");

        return successResponse("Data subject deleted successfully", 200, resp);
    }
}
