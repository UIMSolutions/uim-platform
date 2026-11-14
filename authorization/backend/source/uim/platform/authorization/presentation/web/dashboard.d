/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Server-side rendered dashboard (vibe.d Diet template views/dashboard.dt,
/// styled with daisyUI): tenant figures, applications, policies and the
/// latest decisions. Read-only; tenant from ?tenant=, X-Tenant-Id or token.
module uim.platform.authorization.presentation.web.dashboard;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, render;
import uim.platform.service.presentation.odata;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// View model of the dashboard (plain strings, ready to render).
struct DashboardView {
  string title;
  string tenant;
  string version_;
  string[2][] figures; /// [label, value]
  string[][] applications; /// name, organization, APIs, policies
  string[][] policies; /// name, application, resource, action, conditions, kind, status, assignments
  string[][] decisions; /// time, principal, application, resource, action, allowed, reason
}

class DashboardController {
  protected ODataEngine engine;
  protected SecuritySetup security;
  protected AuthorizationConfig config;

  this(ODataEngine engine, SecuritySetup security, AuthorizationConfig config) {
    this.engine = engine;
    this.security = security;
    this.config = config;
  }

  void registerRoutes(URLRouter router) {
    router.get(config.webPath, &handle);
    router.get(config.webPath ~ "/", &handle);
    router.get(config.apiPath ~ "/web", &handle); // path of the previous release
  }

  DashboardView build(const RequestContext ctx) @trusted {
    DashboardView v;
    v.title = "Authorization Management";
    v.tenant = ctx.tenantId;
    v.version_ = config.serviceVersion;

    auto stats = engine.read(ctx, "Statistics", "");
    foreach (pair; [["Applications", "applications"], ["Policies", "policies"], ["Disabled", "disabledPolicies"],
        ["Assignments", "assignments"], ["Principals", "principals"], ["Permitted", "permittedDecisions"],
        ["Denied", "deniedDecisions"]])
      v.figures ~= [pair[0], stats[pair[1]].toString];

    string cell(Json row, string name) {
      auto value = row[name];
      return value.type == Json.Type.string ? value.get!string : (value.type == Json.Type.null_ ? "" : value.toString);
    }

    foreach (row; engine.query(ctx, "Applications", ["$orderby": "name"]).rows)
      v.applications ~= ["name", "organizationId", "apiCount", "policyCount"].map!(n => cell(row, n)).array;
    foreach (row; engine.query(ctx, "Policies", ["$orderby": "applicationName,name"]).rows)
      v.policies ~= ["name", "applicationName", "resource", "action", "conditions", "kind", "status",
        "assignmentCount"].map!(n => cell(row, n)).array;
    foreach (row; engine.query(ctx, "Decisions", ["$top": "15"]).rows)
      v.decisions ~= [cell(row, "createdAt").replace("T", " ").stripRight("Z"), cell(row, "principalId"),
        cell(row, "applicationName"), cell(row, "resource"), cell(row, "action"), cell(row, "allowed"),
        cell(row, "reason")];
    return v;
  }

  void handle(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    auto ctx = security.resolve(req, "web");
    auto tenant = req.query.get("tenant", "");
    if (tenant.length > 0 && !security.requireAuthentication)
      ctx.tenantId = tenant;
    if (security.requireAuthentication && !ctx.authenticated) {
      res.writeBody("A valid bearer token is required", 401, "text/plain");
      return;
    }
    DashboardView view;
    try
      view = build(ctx);
    catch (EntitySetException e) {
      res.writeBody(e.msg, e.status, "text/plain");
      return;
    }
    res.render!("dashboard.dt", view);
  }
}
