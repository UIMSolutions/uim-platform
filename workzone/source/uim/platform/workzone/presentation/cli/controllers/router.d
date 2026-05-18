/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.cli.controllers.router;

import uim.platform.workzone;
import uim.platform.workzone.presentation.cli.models.workspace;
import uim.platform.workzone.presentation.cli.models.task;
import uim.platform.workzone.presentation.cli.controllers.workspace;
import uim.platform.workzone.presentation.cli.controllers.task;
import std.stdio : writeln;

@safe:
/// Top-level CLI router — dispatches argv tokens to domain-specific controllers.
///
/// Usage:
///   workzone <resource> <subcommand> [options]
///
///   workzone workspace list
///   workzone workspace create --name="My WS"
///   workzone task list --assignee=user1
///   workzone task complete <id>
///   workzone help
class CliRouter {
    private WorkspaceCliController _workspaceCtrl;
    private TaskCliController      _taskCtrl;

    this(ManageWorkspacesUseCase workspacesUC,
         ManageTasksUseCase tasksUC,
         string tenantId) {
        auto wsModel   = WorkspaceCliModel(workspacesUC, tenantId);
        auto taskModel = TaskCliModel(tasksUC, tenantId);
        _workspaceCtrl = new WorkspaceCliController(wsModel);
        _taskCtrl      = new TaskCliController(taskModel);
    }

    /// Process command-line arguments. Returns exit code (0 = success).
    int run(string[] args) {
        // args[0] is the program name; we work with args[1 ..]
        if (args.length < 2) { printHelp(); return 1; }
        immutable resource = args[1];
        immutable rest     = args.length > 2 ? args[2 .. $] : [];

        switch (resource) {
            case "workspace": return _workspaceCtrl.dispatch(rest);
            case "task":      return _taskCtrl.dispatch(rest);
            case "help":      printHelp(); return 0;
            default:
                writeln("Unknown resource: " ~ resource);
                printHelp();
                return 1;
        }
    }

    private static void printHelp() {
        writeln();
        writeln("  workzone — SAP WorkZone CLI");
        writeln("  ─────────────────────────────────────────");
        writeln("  workzone workspace <subcommand> [options]");
        writeln("  workzone task      <subcommand> [options]");
        writeln("  workzone help");
        writeln();
        writeln("  Run 'workzone workspace' or 'workzone task' for sub-command help.");
        writeln();
    }
}
