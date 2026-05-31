/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.cli.controllers.task;

import uim.platform.workzone;
import uim.platform.workzone.presentation.cli.models.task;
import uim.platform.workzone.presentation.cli.views.table_view;
import uim.platform.workzone.presentation.cli.views.detail_view;

import std.datetime : SysTime, unixTimeToStdTime;
import std.format  : format;

@safe:
/// CLI controller for task inbox sub-commands.
///
/// Commands:
///   task list   [--assignee=<id>] [--status=open|inProgress|completed|cancelled]
///   task get    <id>
///   task complete <id>
class TaskCliController {
    private TaskCliModel _model;

    this(TaskCliModel model) { _model = model; }

    int dispatch(string[] args) {
        if (args.length == 0) { printHelp(); return 1; }
        switch (args[0]) {
            case "list":     return cmdList(args[1 .. $]);
            case "get":
                if (args.length >= 2) return cmdGet(args[1]);
                printHelp();
                return 1;
            case "complete":
                if (args.length >= 2) return cmdComplete(args[1]);
                printHelp();
                return 1;
            default:         printHelp(); return 1;
        }
    }

    private int cmdList(string[] args) {
        string assignee, status;
        foreach (arg; args) {
            if (arg.length > 11 && arg[0 .. 11] == "--assignee=") {
                assignee = arg[11 .. $];
            } else if (arg.length > 9 && arg[0 .. 9] == "--status=") {
                status = arg[9 .. $];
            }
        }

        WZTask[] tasks;
        if (assignee.length > 0)
            tasks = _model.listByAssignee(assignee);
        else if (status.length > 0)
            tasks = _model.listByStatus(status);
        else
            tasks = _model.list();

        auto tv = TableView(["ID", "Title", "Priority", "Status", "Assignee", "Due"]);
        foreach (t; tasks) {
            tv.addRow(
                t.id.value,
                truncate(t.title, 40),
                t.priority.to!string,
                t.status.to!string,
                t.assigneeName,
                fmtTs(t.dueDate)
            );
        }
        tv.render();
        return 0;
    }

    private int cmdGet(string id) {
        auto t  = _model.get(id);
        auto dv = DetailView("Task");
        if (t.isNull) {
            dv.renderError("Task '" ~ id ~ "' not found.");
            return 1;
        }
        dv.add("ID",          t.id.value);
        dv.add("Title",       t.title);
        dv.add("Description", t.description);
        dv.add("Status",      t.status.to!string);
        dv.add("Priority",    t.priority.to!string);
        dv.add("Assignee",    t.assigneeName);
        dv.add("Creator",     t.creatorName);
        dv.add("Source App",  t.sourceApp);
        dv.add("Action URL",  t.actionUrl);
        dv.add("Due Date",    fmtTs(t.dueDate));
        dv.render();
        return 0;
    }

    private int cmdComplete(string id) {
        auto result = _model.complete(id);
        auto dv     = DetailView("complete");
        if (result.success)
            dv.renderSuccess("Task '" ~ id ~ "' marked as completed.");
        else
            dv.renderError(result.message);
        return result.success ? 0 : 1;
    }

    private static string truncate(string s, size_t max_) @safe pure {
        return s.length <= max_ ? s : s[0 .. max_] ~ "…";
    }

    private static string fmtTs(long ts) @safe {
        if (ts == 0) return "—";
        auto st = SysTime(unixTimeToStdTime(ts));
        return format!"%04d-%02d-%02d"(st.year, cast(int) st.month, st.day);
    }

    private static void printHelp() {
        import std.stdio : writeln;
        writeln("Usage: workzone task <subcommand> [options]");
        writeln("  list [--assignee=<id>] [--status=open|inProgress|completed]");
        writeln("  get  <id>        Show task detail");
        writeln("  complete <id>    Mark task as completed");
    }
}
