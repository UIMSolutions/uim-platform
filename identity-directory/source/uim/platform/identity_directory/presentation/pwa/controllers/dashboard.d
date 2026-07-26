/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.pwa.controllers.dashboard;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:

class PwaController : ManageHttpController {
  this() {
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/pwa", &handleDashboard);
    router.get("/pwa/", &handleDashboard);
    router.get("/pwa/index.html", &handleDashboard);
    router.get("/pwa/manifest.webmanifest", &handleManifest);
    router.get("/pwa/sw.js", &handleServiceWorker);
  }

  private void handleDashboard(HTTPServerRequest req, HTTPServerResponse res) @safe {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "default");
      auto model = buildPwaPageModel(tenantId);
      auto html = PwaDashboardView.render(model);
      res.writeBody(html, cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    } catch (Exception e) {
      res.writeBody("<h1>Identity Directory PWA</h1><p>Unable to render the dashboard.</p>",
          cast(int) HTTPStatus.internalServerError, "text/html; charset=utf-8");
    }
  }

  private void handleManifest(HTTPServerRequest req, HTTPServerResponse res) @safe {
    res.writeBody(PwaDashboardView.renderManifest(), cast(int) HTTPStatus.ok,
        "application/manifest+json; charset=utf-8");
  }

  private void handleServiceWorker(HTTPServerRequest req, HTTPServerResponse res) @safe {
    res.writeBody(PwaDashboardView.renderServiceWorker(), cast(int) HTTPStatus.ok,
        "application/javascript; charset=utf-8");
  }
}