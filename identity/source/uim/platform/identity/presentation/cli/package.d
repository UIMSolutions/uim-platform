/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// CLI MVC layer for the Identity Service.
/// Model: uses application use cases as model source.
/// View: renders output to stdout.
/// Controller: parses argv commands and dispatches to use cases.
module uim.platform.identity.presentation.cli;

import uim.platform.identity;

@safe:

/// CLI view — renders identity entities to stdout
class IdentityCliView {
    void renderUsers(User[] users) {
        import std.stdio : writefln;
        writefln("%-36s  %-30s  %-40s  %-10s", "ID", "UserName", "Email", "Status");
        writefln("%s", "-".replicate(120));
        foreach (u; users)
            writefln("%-36s  %-30s  %-40s  %-10s", u.id.value, u.userName, u.email, u.status.to!string);
    }

    void renderGroups(Group[] groups) {
        import std.stdio : writefln;
        writefln("%-36s  %-30s  %-12s  Members", "ID", "Name", "Type");
        writefln("%s", "-".replicate(100));
        foreach (g; groups)
            writefln("%-36s  %-30s  %-12s  %d", g.id.value, g.name, g.type_.to!string, g.memberIds.length);
    }

    void renderApplications(Application[] apps) {
        import std.stdio : writefln;
        writefln("%-36s  %-30s  %-6s  %-10s", "ID", "Name", "Proto", "Status");
        writefln("%s", "-".replicate(90));
        foreach (a; apps)
            writefln("%-36s  %-30s  %-6s  %-10s", a.id.value, a.name, a.protocol.to!string, a.status.to!string);
    }

    void renderProvisioningJobs(ProvisioningJob[] jobs) {
        import std.stdio : writefln;
        writefln("%-36s  %-25s  %-6s  %-10s", "ID", "Name", "Type", "Status");
        writefln("%s", "-".replicate(85));
        foreach (j; jobs)
            writefln("%-36s  %-25s  %-6s  %-10s", j.id.value, j.name, j.type_.to!string, j.status.to!string);
    }

    void renderError(string message) {
        import std.stdio : stderr;
        stderr.writefln("[ERROR] %s", message);
    }

    void renderSuccess(string message) {
        import std.stdio : writefln;
        writefln("[OK] %s", message);
    }
}

/// CLI controller — entry point for CLI mode
class IdentityCliController {
    private ManageUsersUseCase userUseCase;
    private ManageGroupsUseCase groupUseCase;
    private ManageApplicationsUseCase appUseCase;
    private ManageProvisioningJobsUseCase jobUseCase;
    private IdentityCliView view;

    this(ManageUsersUseCase u, ManageGroupsUseCase g,
         ManageApplicationsUseCase a, ManageProvisioningJobsUseCase j) {
        userUseCase = u;
        groupUseCase = g;
        appUseCase = a;
        jobUseCase = j;
        view = new IdentityCliView();
    }

    void dispatch(TenantId tenantId, string[] args) {
        if (args.length < 2) { view.renderError("Usage: identity <users|groups|applications|jobs> <list>"); return; }
        switch (args[0]) {
            case "users":
                if (args[1] == "list") view.renderUsers(userUseCase.listUsers(tenantId));
                break;
            case "groups":
                if (args[1] == "list") view.renderGroups(groupUseCase.listGroups(tenantId));
                break;
            case "applications":
                if (args[1] == "list") view.renderApplications(appUseCase.listApplications(tenantId));
                break;
            case "jobs":
                if (args[1] == "list") view.renderProvisioningJobs(jobUseCase.listJobs(tenantId));
                break;
            default:
                view.renderError("Unknown command: " ~ args[0]);
        }
    }
}
