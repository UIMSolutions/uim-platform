module uim.platform.snowflake.presentation.http.health;
import uim.platform.snowflake;
import vibe.http.server;
import vibe.http.router;
mixin(ShowModule!());
@safe:
class HealthController : SAPController {
  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/health", &handleHealth);
  }

  void handleHealth(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = Json.emptyObject;
    j["status"]  = Json("ok");
    j["service"] = Json("SAP Snowflake");
    j["version"] = Json("1.0.0");
    res.writeJsonBody(j, cast(int) HTTPStatus.ok);
  }
}
