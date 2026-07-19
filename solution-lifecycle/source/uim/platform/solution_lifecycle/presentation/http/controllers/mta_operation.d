/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.presentation.http.controllers.mta_operation;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

/// REST /api/v1/slm/operations — list, get, poll, abort async MTA operations.
class MtaOperationController : ManageHttpController {
    private ManageMtaOperationsUseCase usecase;

    this(ManageMtaOperationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/slm/operations", &handleList);
        router.get("/api/v1/slm/operations/*", &handleGet);
        router.post("/api/v1/slm/operations/*/poll", &handlePoll);
        router.post("/api/v1/slm/operations/*/abort", &handleAbort);
        router.get("/api/v1/slm/operations/*/logs", &handleLogs);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto ops = usecase.listOperations(tenantId).map!(op => op.toJson()).array.toJson;
        return successResponse("Operations retrieved successfully", "Retrieved", 200, Json.emptyObject.set(
                "operations", ops).set("count", ops.length));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        // /api/v1/slm/operations/{id}  — exclude sub-paths like /poll /abort /logs
        auto id = MtaOperationId(precheck.id);
        auto op = usecase.getOperation(tenantId, id);
        if (op.isNull)
            return errorResponse("Operation not found", 404);

        return successResponse("Operation retrieved successfully", "Retrieved", 200, op.toJson());
    }

    protected Json pollHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;

        // path: /api/v1/slm/operations/{id}/poll  — strip /poll suffix
        import std.string : indexOf;

        auto bare = path[0 .. path.indexOf("/poll")];
        auto id = MtaOperationId(extractIdFromPath(bare));
        auto result = usecase.pollOperation(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto op = usecase.getOperation(tenantId, id);
        return successResponse("Operation polled successfully", "Polled", 200, op.toJson());
    }

    mixin(HandleTemplate!("handlePoll", "pollHandler"));

    protected Json abortHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;

        
            auto data = precheck.data;
            AbortOperationRequest r;
            r.tenantId = tenantId;
            auto path = precheck.path;
            import std.string : indexOf;

            auto bare = path[0 .. path.indexOf("/abort")];
            r.operationId = extractIdFromPath(bare);
            r.abortedBy = data.getString("abortedBy");

            auto result = usecase.abortOperation(r);
            if (result.hasError)
                return errorResponse(result.message, 400);
            
            return successResponse("Operation aborted successfully", "Aborted", 200, Json.emptyObject.set("id", r.operationId));
}

mixin(HandleTemplate!("handleAbort", "abortHandler"));

protected void handleLogs(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        import std.string : indexOf;

        auto bare = path[0 .. path.indexOf("/logs")];
        auto id = MtaOperationId(extractIdFromPath(bare));
        auto lines = usecase.getOperationLogs(tenantId, id);
        auto arr = Json.emptyArray;
        foreach (l; lines)
            arr ~= Json(l);
        res.writeJsonBody(Json.emptyObject.set("logs", arr), 200);
    } catch (Exception e) {
        writeError(res, 500, "Internal server error");
    }
}
}
