/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.presentation.http.controllers.document_translation;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// POST /api/v1/translation/documents/translate          — synchronous document translation
/// POST /api/v1/translation/documents/translate/async    — submit async document translation job
class DocumentTranslationController : HttpController {
    private PerformTranslationUseCase usecase;

    this(PerformTranslationUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/translation/documents/translate", &handleSyncTranslate);
        router.post("/api/v1/translation/documents/translate/async", &handleAsyncTranslate);
    }

    /// Translate document content synchronously — returns translated content in the response.
    protected void handleSyncTranslate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            TranslateDocumentRequest r;
            r.tenantId = precheck.tenantId;
            r.sourceLanguage = data.getString("sourceLanguage");
            r.targetLanguage = data.getString("targetLanguage");
            r.provider = data.getString("provider");
            r.content = data.getString("content");
            r.contentType = data.getString("contentType", "text/plain");

            auto result = usecase.translateDocument(r);
            if (result.getString("status") == "error") {
                writeError(res, 400, result.getString("message"));
                return;
            }

            res.writeJsonBody(result, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    /// Redirect async requests to the TranslationJobController.
    /// Clients should POST to /api/v1/translation/jobs instead.
    protected void handleAsyncTranslate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            res.writeJsonBody(
                Json.emptyObject
                    .set("message", "Use POST /api/v1/translation/jobs to submit an async translation job")
                    .set("endpoint", "/api/v1/translation/jobs"),
                307
            );
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
