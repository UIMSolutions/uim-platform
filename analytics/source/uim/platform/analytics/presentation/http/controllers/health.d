module uim.platform.analytics.presentation.http.controllers.health;

import vibe.data.json : Json;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.analytics;

mixin(ShowModule!());

@safe:
class AnalyticsHealthController {
  void registerRoutes(URLRouter router) {
    router.get("/api/v1/health", &handleHealth);
  }

  private void handleHealth(HTTPServerRequest req, HTTPServerResponse res) {
    auto payload = Json.emptyObject;
    payload["status"] = Json("UP");
    payload["service"] = Json("Analytics");
    res.writeJsonBody(payload, 200);
  }
}
