module presentation.http.health_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;

/// Health check controller.
class HealthController
{
    void registerRoutes(URLRouter router)
    {
        router.get("/api/v1/health", &handleHealth);
    }

    private void handleHealth(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        auto response = Json.emptyObject;
        response["status"] = Json("UP");
        response["service"] = Json("cloud-portal");
        res.writeJsonBody(response, 200);
    }
}
