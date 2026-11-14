/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Serves the SAP Fiori / UI5 application (frontend/) directly from the backend.
/// Intended for local development without approuter; on Cloud Foundry the
/// approuter (or HTML5 repository) serves the static content instead.
module uim.platform.abap_environment.presentation.web.frontend;

import std.file : exists, isDir;
import vibe.http.router : URLRouter;
import vibe.http.fileserver : serveStaticFiles;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

class FrontendController {
  protected string directory;

  this(string directory) {
    this.directory = directory;
  }

  /// True if the configured directory contains a UI5 app.
  bool available() const {
    return directory.length > 0 && directory.exists && directory.isDir
      && (directory ~ "/index.html").exists;
  }

  /// Serve the app at "/" (index.html) — register AFTER all API routes, since
  /// this is a catch-all for GET requests. The UI5 manifest uses relative URIs
  /// ("odata/v4/abap-environment/"), so the same build works behind the approuter.
  void registerRoutes(URLRouter router) {
    if (!available)
      return;
    router.get("*", serveStaticFiles(directory));
  }
}
