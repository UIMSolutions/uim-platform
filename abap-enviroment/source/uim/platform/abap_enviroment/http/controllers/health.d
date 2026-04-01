module uim.platform.abap_enviroment.http.controllers.health;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;

import uim.platform.abap_enviroment;

mixin(ShowModule!());
@safe:

class HealthController : SAPController {
    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/health", &handleHealth);
    }

    private void handleHealth(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto j = Json.emptyObject;
        j["status"] = Json("UP");
        j["service"] = Json("abap-environment");
        res.writeJsonBody(j, 200);
    }
}
