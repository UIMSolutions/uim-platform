/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// CLI MVC layer for the Print Service.
/// Model: uses application use cases as model source.
/// View: renders output to stdout.
/// Controller: parses argv commands and dispatches to use cases.
module uim.platform.print.presentation.cli;

import uim.platform.print;

@safe:

/// CLI view — renders print queue/task/printer info to stdout
class PrintCliView {
    void renderQueues(PrintQueue[] queues) {
        import std.stdio : writefln;
        writefln("%-36s  %-30s  %-10s", "ID", "Name", "Status");
        writefln("%s", "-".replicate(80));
        foreach (q; queues)
            writefln("%-36s  %-30s  %-10s", q.id.value, q.name, q.status.to!string);
    }

    void renderTasks(PrintTask[] tasks) {
        import std.stdio : writefln;
        writefln("%-36s  %-36s  %-12s  Copies", "Task ID", "Queue ID", "Status");
        writefln("%s", "-".replicate(95));
        foreach (t; tasks)
            writefln("%-36s  %-36s  %-12s  %d", t.id.value, t.queueId.value, t.status.to!string, t.copies);
    }

    void renderPrinters(Printer[] printers) {
        import std.stdio : writefln;
        writefln("%-36s  %-30s  %-10s  %-20s", "ID", "Name", "Status", "Host");
        writefln("%s", "-".replicate(100));
        foreach (p; printers)
            writefln("%-36s  %-30s  %-10s  %-20s", p.id.value, p.name, p.status.to!string, p.host);
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
class PrintCliController {
    private ManagePrintQueuesUseCase queueUseCase;
    private ManagePrintTasksUseCase taskUseCase;
    private ManagePrintersUseCase printerUseCase;
    private PrintCliView view;

    this(ManagePrintQueuesUseCase q, ManagePrintTasksUseCase t, ManagePrintersUseCase p) {
        this.queueUseCase = q;
        this.taskUseCase = t;
        this.printerUseCase = p;
        this.view = new PrintCliView();
    }

    /// Dispatch a CLI command: ["queues"|"tasks"|"printers"] ["list"]
    void dispatch(string[] args) {
        if (args.length < 2) { view.renderError("Usage: print <queues|tasks|printers> <list>"); return; }
        auto resource = args[1];
        auto action = args.length > 2 ? args[2] : "list";
        TenantId tenantId = TenantId("default");

        switch (resource) {
            case "queues":
                if (action == "list") view.renderQueues(queueUseCase.listPrintQueues(tenantId));
                break;
            case "tasks":
                if (action == "list") view.renderTasks(taskUseCase.listPrintTasks(tenantId));
                break;
            case "printers":
                if (action == "list") view.renderPrinters(printerUseCase.listPrinters(tenantId));
                break;
            default:
                view.renderError("Unknown resource: " ~ resource);
        }
    }
}
