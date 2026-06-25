/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.form;
// import uim.platform.process_automation.application.usecases.manage.forms;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:

class FormController : ManageHttpController {
    private ManageFormsUseCase formUsecase;

    this(ManageFormsUseCase formUsecase) {
        this.formUsecase = formUsecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/process-automation/forms", &handleList);
        router.get("/api/v1/process-automation/forms/*", &handleGet);
        router.post("/api/v1/process-automation/forms", &handleCreate);
        router.put("/api/v1/process-automation/forms/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/forms/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateFormRequest r;
        r.tenantId = tenantId;
        r.projectId = ProjectId(data.getString("projectId"));
        r.formId = FormId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.version_ = data.getString("version");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = formUsecase.createForm(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Form created successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto forms = formUsecase.listForms(tenantId);

        auto jarr = Json.emptyArray;
        foreach (f; forms) {
            jarr ~= Json.emptyObject
                .set("id", f.id)
                .set("name", f.name)
                .set("description", f.description)
                .set("status", f.status.to!string)
                .set("version", f.version_)
                .set("createdAt", f.createdAt)
                .set("updatedAt", f.updatedAt);
        }

        auto resp = Json.emptyObject
            .set("count", forms.length)
            .set("resources", jarr);

        return successResponse("Forms retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = FormId(precheck.id);
        if (id.isNull) 
            return errorResponse("Form ID is required", 400);
        
        auto f = formUsecase.getForm(tenantId, id);
        if (f.isNull) {
            return errorResponse("Form not found", 404);
        }

        auto resp = Json.emptyObject
            .set("id", f.id)
            .set("name", f.name)
            .set("description", f.description)
            .set("status", f.status.to!string)
            .set("version", f.version_)
            .set("projectId", f.projectId)
            .set("createdBy", f.createdBy)
            .set("updatedBy", f.updatedBy)
            .set("createdAt", f.createdAt)
            .set("updatedAt", f.updatedAt);

        return successResponse("Form retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        UpdateFormRequest r;
        r.tenantId = tenantId;
        r.formId = FormId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.version_ = data.getString("version");
        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = formUsecase.updateForm(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Form updated successfully", "Updated", 200, resp);

    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = FormId(precheck.id);
        if (id.isNull) 
            return errorResponse("Form ID is required", 400);

        auto result = formUsecase.deleteForm(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Form deleted successfully", "Deleted", 200, resp);

    }
}
