/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entry point for the SAP WorkZone command-line interface.
/// Build: dub build --config=cli
/// Run:   ./build/uim-workzone-cli workspace list
///        ./build/uim-workzone-cli task list --assignee=user1
version (WorkzoneCli):

module cli_main;

import uim.platform.workzone;
import uim.platform.workzone.presentation.cli.controllers.router;
import std.stdio : writeln;

int main(string[] args) {
    // Read tenant from WORKZONE_TENANT env var or default
    import std.process : environment;
    immutable tenantId = environment.get("WORKZONE_TENANT", "default");

    // Bootstrap infrastructure
    auto config    = loadConfig();
    auto container = buildContainer(config);

    // Route command
    auto router = new CliRouter(
        container.manageWorkspaces,
        container.manageTasks,
        tenantId
    );
    return router.run(args);
}
