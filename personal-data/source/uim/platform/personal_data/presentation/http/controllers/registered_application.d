/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.presentation.http.controllers.registered_application;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class RegisteredApplicationController : ManageHttpController {
    private ManageRegisteredApplicationsUseCase usecase;

    this(ManageRegisteredApplicationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/personal-data/applications", &handleList);
        router.get("/api/v1/personal-data/applications/*", &handleGet);
        router.post("/api/v1/personal-data/applications", &handleCreate);
        router.put("/api/v1/personal-data/applications/*", &handleUpdate);
        router.post("/api/v1/personal-data/applications/*/activate", &handleActivate);
        router.post("/api/v1/personal-data/applications/*/suspend", &handleSuspend);
        router.delete_("/api/v1/personal-data/applications/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto apps = usecase.listApplications(tenantId);
        auto jarr = apps.map!(a => appToJson(a)).array.toJson;

        return successResponse("Applications retrieved", "Retrieved", 200, Json.emptyObject
                .set("count", apps.length)
                .set("resources", jarr));
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = precheck.id;

        CreateRegisteredApplicationRequest r;
        r.tenantId = precheck.tenantId;
        r.id = id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.endpointUrl = data.getString("endpointUrl");
        r.apiVersion = data.getString("apiVersion");
        r.contactEmail = data.getString("contactEmail");
        r.contactName = data.getString("contactName");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createApplication(r);
        if (result.hasError)
            return errorResponse(result.message);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Application registered", "Registered", 201, resp);

    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        if (path.length > 9 && path[$ - 9 .. $] == "/activate")
            return errorResponse("Use the activate endpoint to activate the application");

        if (path.length > 8 && path[$ - 8 .. $] == "/suspend")
            return errorResponse("Use the suspend endpoint to suspend the application");

        auto id = RegisteredApplicationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid application ID");

        auto a = usecase.getApplication(tenantId, id);
        if (a.isNull)
            return errorResponse("Application not found");

        return successResponse("Application retrieved", "Retrieved", 200, a.toJson);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = RegisteredApplicationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid application ID");

        UpdateRegisteredApplicationRequest r;
        r.tenantId = precheck.tenantId;
        r.applicationId = id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.endpointUrl = data.getString("endpointUrl");
        r.apiVersion = data.getString("apiVersion");
        r.contactEmail = data.getString("contactEmail");
        r.contactName = data.getString("contactName");
        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateApplication(r);
        if (result.hasError)
            return errorResponse(result.message);

        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Application updated");

        return successResponse("Application updated", "Updated", 200, resp);
    }

    protected Json activateHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto stripped = path[0 .. $ - 9]; // remove "/activate"
        auto id = RegisteredApplicationId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid application ID");

        auto result = usecase.activateApplication(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message);

        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Application activated");

        return successResponse("Application activated", "Activated", 200, resp);
    }

    protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = activateHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected Json suspendHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto stripped = path[0 .. $ - 8]; // remove "/suspend"
        auto id = RegisteredApplicationId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid application ID");

        auto result = usecase.suspendApplication(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message);

        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Application suspended");

        return successResponse("Application suspended", "Suspended", 200, resp);
    }

    protected void handleSuspend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = suspendHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = RegisteredApplicationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid application ID");

        auto result = usecase.deleteApplication(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message);

        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Application deleted");

        return successResponse("Application deleted", "Deleted", 200, resp);
    }
}
