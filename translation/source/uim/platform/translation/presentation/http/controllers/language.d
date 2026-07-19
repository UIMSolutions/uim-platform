/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.presentation.http.controllers.language;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// GET /api/v1/translation/languages — returns the list of supported BCP-47 language codes.
class LanguageController : ManageHttpController {
    private PerformTranslationUseCase usecase;

    this(PerformTranslationUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/translation/languages", &handleList);
    }

    protected Json listhandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto langs = usecase.supportedLanguages(tenantId);

        auto arr = Json.emptyArray;
        foreach (l; langs)
            arr ~= Json(l);

        auto resp = Json.emptyObject
            .set("languages", arr)
            .set("count", langs.length);

        return successResponse("Supported languages retrieved successfully", "Retrieved", 200, resp);
    }
}
