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

    protected void handleCompile(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CompileRequest r;
            r.tenantId   = req.getTenantId;
            r.programId  = data.getString("programId");
            r.sourceCode = data.getString("sourceCode");

            auto response = usecase.compile(r);
            auto status   = response.success ? 200 : 422;
            res.writeJsonBody(response.toJson(), status);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
