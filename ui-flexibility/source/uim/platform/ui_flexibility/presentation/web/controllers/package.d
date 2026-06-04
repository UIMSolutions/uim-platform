/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.presentation.web.controllers;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Web MVC controller serving HTML views for Flex Changes.
class FlexChangesWebController : ManageHttpController {
  private ManageFlexChangesUseCase usecase;

  this(ManageFlexChangesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/web/changes", &handleListPage);
  }

  override protected void handleListPage(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto changes = usecase.listChanges(tenantId);
      auto html = FlexChangesHtmlView.render(changes);
      res.writeBody(html, cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    } catch (Exception e) {
      res.writeBody("<h1>Error</h1>", cast(int) HTTPStatus.internalServerError, "text/html");
    }
  }
}

/// Web MVC controller serving HTML views for Flex Variants.
class FlexVariantsWebController : ManageHttpController {
  private ManageFlexVariantsUseCase usecase;

  this(ManageFlexVariantsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/web/variants", &handleListPage);
  }

  override protected void handleListPage(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto variants = usecase.listVariants(tenantId);
      auto html = FlexVariantsHtmlView.render(variants);
      res.writeBody(html, cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    } catch (Exception e) {
      res.writeBody("<h1>Error</h1>", cast(int) HTTPStatus.internalServerError, "text/html");
    }
  }
}
