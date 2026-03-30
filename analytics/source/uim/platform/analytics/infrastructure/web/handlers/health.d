module uim.platform.analytics.infrastructure.web.handlers.health;

import vibe.http.server;
import vibe.data.json;

class HealthHandler {
    void check(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto j = Json.emptyObject;
        j["status"] = "healthy";
        j["service"] = "analytics";
        j["version"] = "1.0.0";
        res.writeJsonBody(j);
    }
}
