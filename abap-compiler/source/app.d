/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.abap_compiler;
import std.algorithm : canFind;

// mixin(ShowModule!());

@safe:

version (unittest) {
} else {
    void main(string[] args) @trusted {
        auto config    = SrvConfig.load();
        auto container = buildContainer(config);

        // CLI mode: --cli flag launches the interactive REPL instead of HTTP server
        if (args.canFind("--cli")) {
            auto cliRunner = AbapCliRunner(container.compile, "default");
            cliRunner.run();
            return;
        }

        auto router = new URLRouter();

        // Register all controller routes (driving adapters)
        container.programController.registerRoutes(router);
        container.compileController.registerRoutes(router);
        container.jobController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port          = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================");
        writefln("  UIM ABAP Compiler Service");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("                                                          ");
        writefln("  ABAP Compiler Endpoints (Release 7.51):                ");
        writefln("    CRUD   /api/v1/abap/programs    (program repository) ");
        writefln("    POST   /api/v1/abap/compile      (compile source)    ");
        writefln("    GET    /api/v1/abap/jobs         (job list)          ");
        writefln("    GET    /api/v1/abap/jobs/:id     (job detail)        ");
        writefln("                                                          ");
        writefln("  Health:                                                 ");
        writefln("    GET    /api/v1/health                                 ");
        writefln("                                                          ");
        writefln("  CLI:  run with --cli for interactive compiler REPL     ");
        writefln("==========================================================");

        runApplication();
    }
}
