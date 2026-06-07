/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.presentation.http.controllers.domain_;

import uim.platform.translation;

// mixin(ShowModule!());

@safe:

/// GET /api/v1/translation/domains — returns the list of translation domains.
class DomainController : HttpController {

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/translation/domains", &handleList);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            static immutable string[] domains = [
                "IT", "HR", "Finance", "Legal", "Supply Chain", "Manufacturing",
                "Sales", "Marketing", "Customer Service", "Healthcare", "Education",
                "Government", "Retail", "Automotive", "Banking", "Insurance",
                "Energy", "Telecommunications", "Travel", "Logistics",
            ];

            auto arr = Json.emptyArray;
            foreach (d; domains)
                arr ~= Json(d);

            auto resp = Json.emptyObject
                .set("domains", arr)
                .set("count", domains.length);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
