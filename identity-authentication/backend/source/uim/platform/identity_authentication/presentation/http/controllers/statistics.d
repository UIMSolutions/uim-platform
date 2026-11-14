/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// GET {api}/statistics — tenant figures.
module uim.platform.identity_authentication.presentation.http.controllers.statistics;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class StatisticsController : IdentityHttpController {
  protected IIdentityStatisticsService statistics;

  this(IIdentityStatisticsService statistics, string apiPath = "/api/v1", string defaultTenant = "default",
      ITokenService verifier = null) {
    super(apiPath, "statistics", defaultTenant, verifier);
    this.statistics = statistics;
  }

  override void registerRoutes(URLRouter router) {
    router.get(basePath, &get);
  }

  void get(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => reply(res, 200, "Statistics retrieved", statistics.statistics(identity(req).tenantId).toJson));
  }
}
