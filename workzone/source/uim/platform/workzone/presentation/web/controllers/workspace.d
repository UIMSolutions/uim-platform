/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.controllers.workspace;

import uim.platform.workzone;
import uim.platform.workzone.presentation.web.models.workspace;
import uim.platform.workzone.presentation.web.views.workspace;
import uim.platform.workzone.presentation.web.views.error;

mixin(ShowModule!());

@safe:
/// Web MVC controller — renders HTML pages for workspace management.
/// Routes are mounted under /ui/workspaces by WebRouter.
class WorkspaceWebController : PlatformController {
    private ManageWorkspacesUseCase useCase;

    this(ManageWorkspacesUseCase useCase) {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/ui/workspaces",        &handleList);
        router.get("/ui/workspaces/new",    &handleNewForm);
        router.get("/ui/workspaces/*",      &handleDetail);
        router.get("/ui/workspaces/*/edit", &handleEditForm);
    }

    // ── List ──────────────────────────────────────────────────────────────
    private void handleList(scope HTTPServerRequest req,
                            scope HTTPServerResponse res) {
        immutable tenantId = req.getTenantId;
        try {
            auto workspaces = useCase.listWorkspaces(tenantId);
            WorkspaceListViewModel vm;
            vm.tenantId = tenantId;
            foreach (ws; workspaces)
                vm.items ~= WorkspaceListItem.from(ws);
            res.writeBody(renderWorkspaceList(vm), "text/html; charset=utf-8");
        } catch (Exception e) {
            WorkspaceListViewModel vm;
            vm.errorMessage = e.msg;
            res.statusCode = 500;
            res.writeBody(renderWorkspaceList(vm), "text/html; charset=utf-8");
        }
    }

    // ── Detail ────────────────────────────────────────────────────────────
    private void handleDetail(scope HTTPServerRequest req,
                              scope HTTPServerResponse res) {
        immutable tenantId = req.getTenantId;
        immutable id       = extractIdFromPath(req);
        // skip sub-routes like /ui/workspaces/new (handled by handleNewForm)
        if (id == "new") { handleNewForm(req, res); return; }

        try {
            auto ws = useCase.getWorkspace(tenantId, WorkspaceId(id));
            if (ws.isNull) {
                res.statusCode = 404;
                res.writeBody(renderNotFound("Workspace", id), "text/html; charset=utf-8");
                return;
            }
            WorkspaceDetailViewModel vm;
            vm.workspace = WorkspaceViewModel.from(ws);
            res.writeBody(renderWorkspaceDetail(vm), "text/html; charset=utf-8");
        } catch (Exception e) {
            res.statusCode = 500;
            res.writeBody(renderError(500, "Internal Server Error", e.msg),
                          "text/html; charset=utf-8");
        }
    }

    // ── New form ──────────────────────────────────────────────────────────
    private void handleNewForm(scope HTTPServerRequest req,
                               scope HTTPServerResponse res) {
        res.writeBody(renderWorkspaceForm("", "", "", "", "team", ""),
                      "text/html; charset=utf-8");
    }

    // ── Edit form ─────────────────────────────────────────────────────────
    private void handleEditForm(scope HTTPServerRequest req,
                                scope HTTPServerResponse res) {
        immutable tenantId = req.getTenantId;
        // Path: /ui/workspaces/{id}/edit  → second-to-last segment is the id
        immutable rawPath = req.requestPath.to!string;
        immutable id = extractSegmentBeforeLast(rawPath, '/');

        try {
            auto ws = useCase.getWorkspace(tenantId, WorkspaceId(id));
            if (ws.isNull) {
                res.statusCode = 404;
                res.writeBody(renderNotFound("Workspace", id), "text/html; charset=utf-8");
                return;
            }
            res.writeBody(
                renderWorkspaceForm(ws.id.value, ws.name, ws.description,
                                    ws.alias_, ws.type.to!string, ""),
                "text/html; charset=utf-8"
            );
        } catch (Exception e) {
            res.statusCode = 500;
            res.writeBody(renderError(500, "Internal Server Error", e.msg),
                          "text/html; charset=utf-8");
        }
    }
}

/// Extract the path segment immediately before the last `/` separator.
private string extractSegmentBeforeLast(string path, char sep) @safe pure {
    import std.string : lastIndexOf;
    immutable last  = lastIndexOf(path, sep);
    if (last <= 0) return path;
    immutable prev  = lastIndexOf(path[0 .. last], sep);
    return path[prev + 1 .. last];
}
