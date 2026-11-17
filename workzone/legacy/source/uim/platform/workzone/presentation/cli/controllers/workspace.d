/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.cli.controllers.workspace;

import uim.platform.workzone;
import uim.platform.workzone.presentation.cli.models.workspace;
import uim.platform.workzone.presentation.cli.views.table_view;
import uim.platform.workzone.presentation.cli.views.detail_view;


@safe:
/// CLI controller for workspace sub-commands.
///
/// Commands:
///   workspace list
///   workspace get    <id>
///   workspace create --name=... [--desc=...] [--alias=...] [--type=team|project|...]
///   workspace delete <id>
class WorkspaceCliController {
    private WorkspaceCliModel _model;

    this(WorkspaceCliModel model) { _model = model; }

    /// Dispatch a workspace sub-command.
    /// `args` are the tokens after "workspace".
    int dispatch(string[] args) {
        if (args.length == 0) { printHelp(); return 1; }
        switch (args[0]) {
            case "list":   return cmdList();
            case "get":
                if (args.length >= 2) return cmdGet(args[1]);
                printHelp();
                return 1;
            case "create": return cmdCreate(args[1 .. $]);
            case "delete":
                if (args.length >= 2) return cmdDelete(args[1]);
                printHelp();
                return 1;
            default:       printHelp(); return 1;
        }
    }

    private int cmdList() {
        auto ws = _model.list();
        auto tv = TableView(["ID", "Name", "Alias", "Type", "Status", "Members"]);
        foreach (w; ws) {
            tv.addRow(w.id.value, w.name, w.alias_,
                      w.type.to!string, w.status.to!string,
                      w.members.length.to!string);
        }
        tv.render();
        return 0;
    }

    private int cmdGet(string id) {
        auto ws = _model.get(id);
        auto dv = DetailView("Workspace");
        if (ws.isNull) {
            dv.renderError("Workspace '" ~ id ~ "' not found.");
            return 1;
        }
        dv.add("ID",          ws.id.value);
        dv.add("Name",        ws.name);
        dv.add("Description", ws.description);
        dv.add("Alias",       ws.alias_);
        dv.add("Type",        ws.type.to!string);
        dv.add("Status",      ws.status.to!string);
        dv.add("Members",     ws.members.length.to!string);
        dv.add("Pages",       ws.pageIds.length.to!string);
        dv.render();
        return 0;
    }

    private int cmdCreate(string[] args) {
        string name, desc, alias_, type_ = "team";
        foreach (arg; args) {
            if (arg.length > 7 && arg[0 .. 7] == "--name=") {
                name = arg[7 .. $];
            } else if (arg.length > 7 && arg[0 .. 7] == "--desc=") {
                desc = arg[7 .. $];
            } else if (arg.length > 8 && arg[0 .. 8] == "--alias=") {
                alias_ = arg[8 .. $];
            } else if (arg.length > 7 && arg[0 .. 7] == "--type=") {
                type_ = arg[7 .. $];
            }
        }
        if (name.isEmpty) {
            auto dv = DetailView("create");
            dv.renderError("--name is required.");
            return 1;
        }
        auto result = _model.create(name, desc, alias_, type_);
        auto dv = DetailView("create");
        if (result.success)
            dv.renderSuccess("Workspace created with ID: " ~ result.id);
        else
            dv.renderError(result.message);
        return result.success ? 0 : 1;
    }

    private int cmdDelete(string id) {
        auto result = _model.remove(id);
        auto dv = DetailView("delete");
        if (result.success)
            dv.renderSuccess("Workspace '" ~ id ~ "' deleted.");
        else
            dv.renderError(result.message);
        return result.success ? 0 : 1;
    }

    private static void printHelp() {
        import std.stdio : writeln;
        writeln("Usage: workzone workspace <subcommand> [options]");
        writeln("  list                        List all workspaces");
        writeln("  get    <id>                 Get workspace detail");
        writeln("  create --name=<n> [options] Create a workspace");
        writeln("         --desc=<d>   description");
        writeln("         --alias=<a>  URL slug");
        writeln("         --type=<t>   team|project|department|public|external");
        writeln("  delete <id>                 Delete a workspace");
    }
}
