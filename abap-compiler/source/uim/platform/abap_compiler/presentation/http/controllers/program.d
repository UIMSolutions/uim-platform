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
class ProgramController : PlatformController {
    private ManageProgramsUseCase usecase;

    this(ManageProgramsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get   ("/api/v1/abap/programs",  &handleList);
        router.post  ("/api/v1/abap/programs",  &handleCreate);
        router.get   ("/api/v1/abap/programs/*",&handleGet);
        router.put   ("/api/v1/abap/programs/*",&handleUpdate);
        router.delete_("/api/v1/abap/programs/*",&handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId  = req.getTenantId;
            auto programs  = usecase.listPrograms(tenantId);
            auto jarr      = Json.emptyArray;
            foreach (p; programs) jarr ~= p.toJson();
            res.writeJsonBody(Json.emptyObject.set("count", cast(long) programs.length).set("items", jarr), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateProgramRequest r;
            r.tenantId    = req.getTenantId;
            r.id          = j.getString("id");
            r.title       = j.getString("title");
            r.language    = j.getString("language", "EN");
            r.sourceCode  = j.getString("sourceCode");
            r.programType = cast(ProgramType) j.getString("programType", "report").to!int;

            auto result = usecase.createProgram(r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Program created"), 201);
            else
                writeError(res, 400, result.message);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto prog     = usecase.getProgram(tenantId, id);
            if (prog.isNull) { writeError(res, 404, "Program not found"); return; }
            res.writeJsonBody(prog.toJson(), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            UpdateProgramRequest r;
            r.tenantId   = req.getTenantId;
            r.id         = extractIdFromPath(req.requestURI.to!string);
            r.title      = j.getString("title");
            r.language   = j.getString("language", "EN");
            r.sourceCode = j.getString("sourceCode");

            auto result = usecase.updateProgram(r);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Program updated"), 200);
            else
                writeError(res, result.message.length > 0 ? 400 : 404, result.message);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id       = extractIdFromPath(req.requestURI.to!string);
            auto result   = usecase.deleteProgram(tenantId, id);
            if (result.success)
                res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Program deleted"), 200);
            else
                writeError(res, 404, result.message);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
