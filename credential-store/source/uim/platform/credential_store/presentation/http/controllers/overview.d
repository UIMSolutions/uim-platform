/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.presentation.http.controllers.overview;
// import uim.platform.credential_store.application.usecases.get_overview;
// import uim.platform.credential_store.application.dto;

import uim.platform.credential_store;

// mixin(ShowModule!());

@safe:

class OverviewController : HttpController {
  private GetOverviewUseCase usecase;

  this(GetOverviewUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/overview", &handleOverview);
  }

  protected Json overviewHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto summary = usecase.getSummary(tenantId);

    auto responseData = Json.emptyObject
      .set("totalNamespaces", summary.totalNamespaces)
      .set("totalCredentials", summary.totalCredentials)
      .set("totalPasswords", summary.totalPasswords)
      .set("totalKeys", summary.totalKeys)
      .set("totalKeyrings", summary.totalKeyrings)
      .set("totalBindings", summary.totalBindings)
      .set("totalAuditEntries", summary.totalAuditEntries);

    return successResponse("Overview retrieved successfully", "Retrieved", 200, responseData);
  }
  
  mixin(HandleTemplate!("handleOverview", "overviewHandler"));

}
