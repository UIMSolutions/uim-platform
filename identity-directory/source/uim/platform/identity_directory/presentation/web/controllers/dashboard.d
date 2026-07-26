/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.web.controllers.dashboard;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:

class IdentityDirectoryWebController {
  private ManageApiClientsUseCase apiClients;
  private QueryAuditLogUseCase auditLog;
  private ManageUsersUseCase users;
  private ManageGroupsUseCase groups;
  private ManageSchemasUseCase schemas;
  private ManagePasswordPoliciesUseCase passwordPolicies;
  private IdentityDirectoryWebView view;

  this(ManageApiClientsUseCase apiClients, QueryAuditLogUseCase auditLog,
      ManageUsersUseCase users, ManageGroupsUseCase groups,
      ManageSchemasUseCase schemas, ManagePasswordPoliciesUseCase passwordPolicies) {
    this.apiClients = apiClients;
    this.auditLog = auditLog;
    this.users = users;
    this.groups = groups;
    this.schemas = schemas;
    this.passwordPolicies = passwordPolicies;
    this.view = IdentityDirectoryWebView();
  }

  void registerRoutes(URLRouter router) {
    router.get("/web/identity-directory", &handleDashboard);
    router.get("/web/identity-directory/api-clients", &handleApiClients);
    router.get("/web/identity-directory/audit", &handleAudit);
    router.get("/web/identity-directory/users", &handleUsers);
    router.get("/web/identity-directory/groups", &handleGroups);
    router.get("/web/identity-directory/schemas", &handleSchemas);
    router.get("/web/identity-directory/password-policies", &handlePasswordPolicies);
  }

  private void handleDashboard(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.query.get("tenantId", "default");
    auto model = buildDashboardModel(tenantId, apiClients.listClients(TenantId(tenantId)).length,
        auditLog.listEvents(TenantId(tenantId)).length,
        users.listUsers(TenantId(tenantId)).length,
        groups.listGroups(TenantId(tenantId)).length,
        schemas.listSchemas(TenantId(tenantId)).length,
        passwordPolicies.listPolicies(TenantId(tenantId)).length);

    res.writeBody(view.renderDashboard(model), cast(int)HTTPStatus.ok,
        "text/html; charset=utf-8");
  }

  private void handleApiClients(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.query.get("tenantId", "default");
    auto model = buildApiClientsModel(tenantId, apiClients.listClients(TenantId(tenantId)));
    res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok, "text/html; charset=utf-8");
  }

  private void handleAudit(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.query.get("tenantId", "default");
    auto model = buildAuditModel(tenantId, auditLog.listEvents(TenantId(tenantId)));
    res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok, "text/html; charset=utf-8");
  }

  private void handleUsers(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.query.get("tenantId", "default");
    auto model = buildUsersModel(tenantId, users.listUsers(TenantId(tenantId)));
    res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok, "text/html; charset=utf-8");
  }

  private void handleGroups(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.query.get("tenantId", "default");
    auto model = buildGroupsModel(tenantId, groups.listGroups(TenantId(tenantId)));
    res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok, "text/html; charset=utf-8");
  }

  private void handleSchemas(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.query.get("tenantId", "default");
    auto model = buildSchemasModel(tenantId, schemas.listSchemas(TenantId(tenantId)));
    res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok, "text/html; charset=utf-8");
  }

  private void handlePasswordPolicies(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = req.query.get("tenantId", "default");
    auto model = buildPasswordPoliciesModel(tenantId,
        passwordPolicies.listPolicies(TenantId(tenantId)));
    res.writeBody(view.renderPage(model), cast(int)HTTPStatus.ok, "text/html; charset=utf-8");
  }
}