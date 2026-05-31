/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_compiler.presentation.http.controllers.compile;

import uim.platform.abap_compiler;

mixin(ShowModule!());
@safe:

/// HTTP controller: trigger ABAP compilation.
/// Endpoints:
///   POST /api/v1/abap/compile   — compile submitted ABAP source inline or by programId
class CompileController : PlatformController {
    private CompileUseCase usecase;

    this(CompileUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/abap/compile", &handleCompile);
    }

    protected Json compileHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto data = precheck.data;
        CompileRequest r;
        r.tenantId = req.getTenantId;
        r.programId = data.getString("programId");
        r.sourceCode = data.getString("sourceCode");

        auto result = usecase.compile(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("result", result.result.toJson());
        return successResponse("Compilation successful", "Compilation failed", 200, responseData);
    }

    protected void handleCompile(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = compileHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
