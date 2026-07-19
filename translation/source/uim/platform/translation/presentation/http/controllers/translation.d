/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.presentation.http.controllers.translation;

import uim.platform.translation;
mixin(ShowModule!());

@safe:

/// POST /api/v1/translation/translate — synchronous software / UI text translation.
class TranslationController : HttpController {
    private PerformTranslationUseCase usecase;

    this(PerformTranslationUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/translation/translate", &handleTranslate);
    }

    protected Json translateHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        TranslateTextRequest r;
        r.tenantId = tenantId;
        r.sourceLanguage = data.getString("sourceLanguage");
        r.targetLanguage = data.getString("targetLanguage");
        r.domainName = data.getString("domain");
        r.textType = data.getString("textType");
        r.provider = data.getString("provider");

        // Accept either "texts" (array) or "text" (single string)
        if (data["texts"].isArray) {
            foreach (item; data["texts"].toArray)
                r.texts ~= item.get!string;
        } else if (data["text"].isString) {
            r.texts ~= data.getString("text");
        }

        auto result = usecase.translateTexts(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
    

        return successResponse("Translation successful", "Translated", 200, result);
    }

    mixin(HandleTemplate!("handleTranslate", "translateHandler"));
}
