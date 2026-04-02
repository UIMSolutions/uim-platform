module presentation.http.health;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;

class HealthController
{
    override void registerRoutes(URLRouter router)
    {
        router.get("/api/v1/health", &handleHealth);
    }

    private void handleHealth(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        auto j = Json.emptyObject;
        j["status"] = Json("UP");
        j["service"] = Json("monitoring");
        res.writeJsonBody(j, 200);
    }
}
