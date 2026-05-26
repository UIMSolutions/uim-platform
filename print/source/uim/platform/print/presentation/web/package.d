/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Web MVC layer for the Print Service.
/// Model: bridges application use cases.
/// View: generates HTML responses (Diet templates or inline HTML).
/// Controller: handles web routes for browser-based UI.
module uim.platform.print.presentation.web;

import uim.platform.print;

@safe:

/// Web view — renders HTML table for print queues
class PrintWebView {
    string renderQueueList(PrintQueue[] queues) {
        import std.array : appender;
        auto buf = appender!string;
        buf ~= "<html><head><title>Print Queues</title></head><body>";
        buf ~= "<h1>Print Queues</h1>";
        buf ~= "<table border='1'><tr><th>ID</th><th>Name</th><th>Status</th><th>Location</th></tr>";
        foreach (q; queues)
            buf ~= "<tr><td>" ~ q.id.value ~ "</td><td>" ~ q.name ~ "</td><td>" ~
                   q.status.to!string ~ "</td><td>" ~ q.location ~ "</td></tr>";
        buf ~= "</table></body></html>";
        return buf[];
    }

    string renderTaskList(PrintTask[] tasks) {
        import std.array : appender;
        import std.conv : to;
        auto buf = appender!string;
        buf ~= "<html><head><title>Print Tasks</title></head><body>";
        buf ~= "<h1>Print Tasks</h1>";
        buf ~= "<table border='1'><tr><th>ID</th><th>Queue</th><th>Status</th><th>Copies</th></tr>";
        foreach (t; tasks)
            buf ~= "<tr><td>" ~ t.id.value ~ "</td><td>" ~ t.queueId.value ~ "</td><td>" ~
                   t.status.to!string ~ "</td><td>" ~ t.copies.to!string ~ "</td></tr>";
        buf ~= "</table></body></html>";
        return buf[];
    }
}

/// Web controller — registers web UI routes
class PrintWebController {
    private ManagePrintQueuesUseCase queueUseCase;
    private ManagePrintTasksUseCase taskUseCase;
    private PrintWebView view;

    this(ManagePrintQueuesUseCase q, ManagePrintTasksUseCase t) {
        this.queueUseCase = q;
        this.taskUseCase = t;
        this.view = new PrintWebView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/print/queues", &handleQueueList);
        router.get("/web/print/tasks", &handleTaskList);
    }

    private void handleQueueList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto tenantId = req.getTenantId;
        auto queues = queueUseCase.listPrintQueues(tenantId);
        res.writeBody(view.renderQueueList(queues), "text/html; charset=utf-8");
    }

    private void handleTaskList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto tenantId = req.getTenantId;
        auto tasks = taskUseCase.listPrintTasks(tenantId);
        res.writeBody(view.renderTaskList(tasks), "text/html; charset=utf-8");
    }
}
