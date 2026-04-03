module uim.platform.service.classes.controllers.health;

import uim.platform.service;

mixin(ShowModule!());

@safe:
class HealthController : SAPController {
  this() {
    super();
  }

  this(string serviceName) {
    super();
    this.serviceName = serviceName;
  }

  protected string _serviceName = "service";
  @property string serviceName() {
    return _serviceName;
  }

  @property void serviceName(string name) {
    _serviceName = name;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/health", &handleHealth);
  }

  private void handleHealth(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto j = Json.emptyObject;
    j["status"] = Json("UP");
    j["service"] = serviceName;
    res.writeJsonBody(j, 200);
  }
}
