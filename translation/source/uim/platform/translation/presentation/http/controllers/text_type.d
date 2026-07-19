/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.presentation.http.controllers.text_type;

import uim.platform.translation;
mixin(ShowModule!());

@safe:

/// GET /api/v1/translation/text-types — returns the list of supported text types.
class TextTypeController : ManageHttpController {

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/translation/text-types", &handleList);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        // Each entry: id + description
        auto arr = Json.emptyArray;
        arr ~= makeTextType("uiText", "UI button labels, menu items, field labels");
        arr ~= makeTextType("tooltip", "Tooltip and help text");
        arr ~= makeTextType("errorMessage", "Error and warning messages");
        arr ~= makeTextType("documentation", "Long-form documentation and descriptions");
        arr ~= makeTextType("notification", "Push notifications and alert messages");
        arr ~= makeTextType("emailBody", "Email body and subject lines");
        arr ~= makeTextType("reportTitle", "Report and chart titles");
        arr ~= makeTextType("log", "Log and audit trail messages");

        auto resp = Json.emptyObject
            .set("textTypes", arr)
            .set("count", 8);

        return successResponse("Supported text types retrieved successfully", "Retrieved", 200, resp);
    
}

private static Json makeTextType(string id, string description) {
    return Json.emptyObject
        .set("id", id)
        .set("description", description);
}
}
