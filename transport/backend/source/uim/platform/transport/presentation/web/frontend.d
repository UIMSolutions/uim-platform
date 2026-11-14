/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Serves the SAP Fiori / UI5 application (frontend/) directly from the backend.
/// Intended for local development without approuter; on Cloud Foundry the
/// approuter serves the static content instead.
module uim.platform.transport.presentation.web.frontend;

import std.file : exists, isDir;
import std.path : buildPath;
import vibe.http.router : URLRouter;
import vibe.http.fileserver : serveStaticFiles;
import uim.platform.transport;

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
      && buildPath(directory, "index.html").exists;
  }

  /// Serve the app at "/" — register AFTER all API routes (catch-all for GET).
  /// The UI5 manifest uses relative URIs ("odata/v4/transport/"), so the same
  /// build works behind the approuter.
  void registerRoutes(URLRouter router) {
    if (!available)
      return;
    router.get("*", serveStaticFiles(directory));
  }
}
