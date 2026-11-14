/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Serves the SAP Fiori app (../frontend) under /app for local development.
/// On SAP BTP the approuter serves it instead (frontendDir = "").
module uim.platform.task_center.presentation.web.frontend;

import vibe.http.fileserver : serveStaticFiles, HTTPFileServerSettings;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class FrontendController {
  protected string dir;

  this(string dir) {
    this.dir = dir;
  }

  bool available() const @trusted {
    import std.file : exists, isDir;
    import std.path : buildPath;

    return dir.length > 0 && exists(dir) && isDir(dir) && exists(buildPath(dir, "index.html"));
  }

  void registerRoutes(URLRouter router) @trusted {
    if (!available)
      return;
    auto fs = new HTTPFileServerSettings;
    fs.serverPathPrefix = "/app";
    router.get("/app/*", serveStaticFiles(dir.stripRight("/") ~ "/", fs));
    router.get("/", (HTTPServerRequest req, HTTPServerResponse res) { res.redirect("/app/index.html"); });
  }
}
