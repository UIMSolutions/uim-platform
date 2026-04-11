/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.overview;

// import uim.platform.credential_store.application.usecases.get_overview;
// import uim.platform.credential_store.application.dto;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:

class OverviewController : PlatformController {
  private GetOverviewUseCase uc;

  this(GetOverviewUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/overview", &handleOverview);
  }

  private void handleOverview(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto summary = uc.getSummary(tenantId);

      auto j = Json.emptyObject
        .set("totalNamespaces", summary.totalNamespaces)
        .set("totalCredentials", summary.totalCredentials)
        .set("totalPasswords", summary.totalPasswords)
        .set("totalKeys", summary.totalKeys)
        .set("totalKeyrings", summary.totalKeyrings)
        .set("totalBindings", summary.totalBindings)
        .set("totalAuditEntries", summary.totalAuditEntries);

      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
