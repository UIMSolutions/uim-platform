/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.presentation.http.controllers.program;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// HTTP controller for ABAP program source artefacts.
/// Endpoints:
///   GET    /api/v1/abap/programs          — list all programs for tenant
///   POST   /api/v1/abap/programs          — create a new program
///   GET    /api/v1/abap/programs/*        — get program by ID
///   PUT    /api/v1/abap/programs/*        — full update
///   DELETE /api/v1/abap/programs/*        — delete
class ProgramController : ManageController {
    private ManageProgramsUseCase usecase;

    this(ManageProgramsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/abap/programs", &handleList);
        router.post("/api/v1/abap/programs", &handleCreate);
        router.get("/api/v1/abap/programs/*", &handleGet);
        router.put("/api/v1/abap/programs/*", &handleUpdate);
        router.delete_("/api/v1/abap/programs/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto programs = usecase.listPrograms(tenantId);
        auto jarr = programs.map!(p => p.toJson).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", programs.length)
            .set("resources", list);

        return successResponse("Program list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        CreateProgramRequest r;
        r.tenantId = tenantId;
        r.title = data.getString("title");
        r.language = data.getString("language", "EN");
        r.sourceCode = data.getString("sourceCode");
        r.programType = cast(ProgramType)data.getString("programType", "report").to!int;

        auto result = usecase.createProgram(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Program created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ProgramId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid program ID", 400);

        auto prog = usecase.getProgram(tenantId, id);
        if (prog.isNull)
            return errorResponse("Program not found", 404);

        auto responseData = prog.toJson();
        return successResponse("Program retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = ProgramId(precheck.id);

        UpdateProgramRequest r;
        r.tenantId = tenantId;
        r.programId = id;
        r.title = data.getString("title");
        r.language = data.getString("language", "EN");
        r.sourceCode = data.getString("sourceCode");

        auto result = usecase.updateProgram(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Program updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ProgramId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid program ID", 400);

        auto result = usecase.deleteProgram(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Program deleted successfully", "Deleted", 200, responseData);
    }
}
