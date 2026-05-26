/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Web MVC layer for the Identity Service.
/// Model: use cases supply model data.
/// View: renders HTML.
/// Controller: registers vibe.d HTTP routes for web browser access.
module uim.platform.identity.presentation.web;

import uim.platform.identity;

@safe:

/// Web view — generates HTML pages
class IdentityWebView {
    string renderUserList(User[] users) {
        import std.array : appender;
        auto html = appender!string;
        html.put("<!DOCTYPE html><html><head><meta charset='utf-8'>");
        html.put("<title>Identity Service - Users</title></head><body>");
        html.put("<h1>Users</h1><table border='1'>");
        html.put("<tr><th>ID</th><th>UserName</th><th>Email</th><th>DisplayName</th><th>Status</th></tr>");
        foreach (u; users) {
            html.put("<tr><td>" ~ u.id.value ~ "</td><td>" ~ u.userName ~ "</td><td>" ~
                u.email ~ "</td><td>" ~ u.displayName ~ "</td><td>" ~ u.status.to!string ~ "</td></tr>");
        }
        html.put("</table></body></html>");
        return html.data;
    }

    string renderGroupList(Group[] groups) {
        import std.array : appender;
        import std.conv : to;
        auto html = appender!string;
        html.put("<!DOCTYPE html><html><head><meta charset='utf-8'>");
        html.put("<title>Identity Service - Groups</title></head><body>");
        html.put("<h1>Groups</h1><table border='1'>");
        html.put("<tr><th>ID</th><th>Name</th><th>Type</th><th>Members</th></tr>");
        foreach (g; groups) {
            html.put("<tr><td>" ~ g.id.value ~ "</td><td>" ~ g.name ~ "</td><td>" ~
                g.type_.to!string ~ "</td><td>" ~ g.memberIds.length.to!string ~ "</td></tr>");
        }
        html.put("</table></body></html>");
        return html.data;
    }

    string renderApplicationList(Application[] apps) {
        import std.array : appender;
        auto html = appender!string;
        html.put("<!DOCTYPE html><html><head><meta charset='utf-8'>");
        html.put("<title>Identity Service - Applications</title></head><body>");
        html.put("<h1>Applications</h1><table border='1'>");
        html.put("<tr><th>ID</th><th>Name</th><th>Protocol</th><th>Status</th></tr>");
        foreach (a; apps) {
            html.put("<tr><td>" ~ a.id.value ~ "</td><td>" ~ a.name ~ "</td><td>" ~
                a.protocol.to!string ~ "</td><td>" ~ a.status.to!string ~ "</td></tr>");
        }
        html.put("</table></body></html>");
        return html.data;
    }
}

/// Web controller — registers browser-facing HTML routes
class IdentityWebController {
    private ManageUsersUseCase userUseCase;
    private ManageGroupsUseCase groupUseCase;
    private ManageApplicationsUseCase appUseCase;
    private IdentityWebView view;

    this(ManageUsersUseCase u, ManageGroupsUseCase g, ManageApplicationsUseCase a) {
        userUseCase = u;
        groupUseCase = g;
        appUseCase = a;
        view = new IdentityWebView();
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/identity/users", &handleUsers);
        router.get("/web/identity/groups", &handleGroups);
        router.get("/web/identity/applications", &handleApplications);
    }

    private void handleUsers(scope HTTPServerRequest req, scope HTTPServerResponse res) @safe {
        try {
            auto tenantId = req.getTenantId;
            auto users = userUseCase.listUsers(tenantId);
            res.writeBody(view.renderUserList(users), cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
        } catch (Exception e) {
            res.writeBody("<h1>Error</h1>", cast(int) HTTPStatus.internalServerError, "text/html");
        }
    }

    private void handleGroups(scope HTTPServerRequest req, scope HTTPServerResponse res) @safe {
        try {
            auto tenantId = req.getTenantId;
            auto groups = groupUseCase.listGroups(tenantId);
            res.writeBody(view.renderGroupList(groups), cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
        } catch (Exception e) {
            res.writeBody("<h1>Error</h1>", cast(int) HTTPStatus.internalServerError, "text/html");
        }
    }

    private void handleApplications(scope HTTPServerRequest req, scope HTTPServerResponse res) @safe {
        try {
            auto tenantId = req.getTenantId;
            auto apps = appUseCase.listApplications(tenantId);
            res.writeBody(view.renderApplicationList(apps), cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
        } catch (Exception e) {
            res.writeBody("<h1>Error</h1>", cast(int) HTTPStatus.internalServerError, "text/html");
        }
    }
}
