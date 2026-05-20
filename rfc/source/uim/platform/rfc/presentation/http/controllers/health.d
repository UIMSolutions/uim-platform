/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.presentation.http.controllers.health;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// Health-check endpoint for Kubernetes liveness and readiness probes.
class HealthController : PlatformController {

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/health", &handleHealth);
    }

    protected void handleHealth(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        res.writeJsonBody(Json.emptyObject
            .set("status",  "UP")
            .set("service", "RFC Interface"), 200);
    }
}
