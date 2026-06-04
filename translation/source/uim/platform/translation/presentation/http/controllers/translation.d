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

    protected void handleTranslate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            TranslateTextRequest r;
            r.tenantId = precheck.tenantId;
            r.sourceLanguage = data.getString("sourceLanguage");
            r.targetLanguage = data.getString("targetLanguage");
            r.domainName = data.getString("domain");
            r.textType = data.getString("textType");
            r.provider = data.getString("provider");

            // Accept either "texts" (array) or "text" (single string)
            if (j["texts"].isArray) {
                foreach (item; j["texts"])
                    r.texts ~= item.get!string;
            } else if (j["text"].isString) {
                r.texts ~= data.getString("text");
            }

            auto result = usecase.translateTexts(r);
            if (result.getString("status") == "error") {
                writeError(res, 400, result.getString("message"));
                return;
            }

            res.writeJsonBody(result, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
