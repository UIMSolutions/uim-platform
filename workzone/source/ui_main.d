/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entry point for the SAP WorkZone desktop GUI application (GtkD).
/// Build: dub build --config=gui
/// Run:   ./build/uim-workzone-gui [--tenant=<id>]
version (WorkzoneGui):

module ui_main;

import uim.platform.workzone;
import uim.platform.workzone.presentation.gui.controllers.app;
import std.getopt : getopt, defaultGetoptPrinter;

int main(string[] args) {
    TenantId tenantId = "default";
    try {
        auto helpInfo = getopt(args, "tenant", "Tenant ID to use", &tenantId);
        if (helpInfo.helpWanted) {
            defaultGetoptPrinter("SAP WorkZone GUI", helpInfo.options);
            return 0;
        }
    } catch (Exception e) {
        import std.stdio : writeln;
        writeln("Error: " ~ e.msg);
        return 1;
    }

    // Build infrastructure
    auto config = loadConfig();
    auto container = buildContainer(config);

    // Launch GTK application
    auto appCtrl = new WorkZoneAppController(
        container.manageWorkspaces,
        container.manageWorkpages,
        container.manageTasks,
        tenantId
    );
    return appCtrl.run(args);
}
