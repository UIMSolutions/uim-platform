/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.controllers.workpage;

import uim.platform.workzone;
import uim.platform.workzone.presentation.web.models.workpage;
import uim.platform.workzone.presentation.web.views.workpage;
import uim.platform.workzone.presentation.web.views.error;

mixin(ShowModule!());

@safe:
/// Web MVC controller — renders HTML for workpage management under a workspace.
/// Routes: /ui/workspaces/{wsId}/pages
class WorkpageWebController : ManageHttpController {
    private ManageWorkpagesUseCase workpageUseCase;
    private ManageWorkspacesUseCase workspaceUseCase;

    this(ManageWorkpagesUseCase workpageUseCase,
         ManageWorkspacesUseCase workspaceUseCase) {
        this.workpageUseCase  = workpageUseCase;
        this.workspaceUseCase = workspaceUseCase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/ui/workspaces/*/pages", &handleList);
    }

    private void handleList(scope HTTPServerRequest req,
                            scope HTTPServerResponse res) {
        immutable tenantId   = req.getTenantId;
        immutable rawPath    = req.requestPath.to!string;
        // /ui/workspaces/{wsId}/pages  → extract {wsId}
        immutable workspaceId = extractSegmentAt(rawPath, 3); // 0-indexed after /ui

        try {
            auto ws    = workspaceUseCase.getWorkspace(tenantId, WorkspaceId(workspaceId));
            auto pages = workpageUseCase.listByWorkspace(tenantId, WorkspaceId(workspaceId));

            WorkpageListViewModel vm;
            vm.workspaceId   = workspaceId;
            vm.workspaceName = ws.isNull ? workspaceId : ws.name;
            foreach (p; pages)
                vm.pages ~= WorkpageViewModel.from(p);

            res.writeBody(renderWorkpageList(vm), "text/html; charset=utf-8");
        } catch (Exception e) {
            res.statusCode = 500;
            res.writeBody(renderError(500, "Internal Server Error", e.msg),
                          "text/html; charset=utf-8");
        }
    }
}

/// Extract the n-th `/`-separated path segment (0 = first).
private string extractSegmentAt(string path, size_t n) @safe pure {
    import std.string : indexOf;
    size_t start = 0;
    size_t count = 0;
    foreach (i, c; path) {
        if (c == '/') {
            if (count == n) {
                // find end
                immutable end = () {
                    foreach (j; i + 1 .. path.length)
                        if (path[j] == '/') return j;
                    return path.length;
                }();
                return path[i + 1 .. end];
            }
            count++;
        }
    }
    return "";
}
