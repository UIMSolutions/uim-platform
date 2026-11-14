/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST adapter for applications (service providers / OAuth clients):
///   GET/POST {api}/applications   GET/PUT/PATCH/DELETE {api}/applications/:id
///   POST {api}/applications/:id/rotate-secret
module uim.platform.identity_authentication.presentation.http.controllers.applications;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class ApplicationController : IdentityHttpController {
  protected IManageApplicationsUseCase applications;

  this(IManageApplicationsUseCase applications, string apiPath = "/api/v1", string defaultTenant = "default",
      ITokenService verifier = null) {
    super(apiPath, "applications", defaultTenant, verifier);
    this.applications = applications;
  }

  override void registerRoutes(URLRouter router) {
    crudRoutes(router, &list, &get, &create, &update, &remove);
    router.post(basePath ~ "/:id/rotate-secret", &rotateSecret);
  }

  void list(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyList(res, applications.listApplications(identity(req).tenantId), "Applications"));
  }

  void get(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto id = param(req, "id");
      replyOne(res, applications.getApplication(identity(req).tenantId, ApplicationId(id)), "Application", id);
    });
  }

  void create(HTTPServerRequest req, HTTPServerResponse res) {
    createWith!ApplicationDTO(req, res, (dto) => applications.createApplication(dto));
  }

  void update(HTTPServerRequest req, HTTPServerResponse res) {
    mergeWith!(ApplicationDTO, Application)(req, res, "Application",
      (t, id) => applications.getApplication(t, ApplicationId(id)), (dto) => applications.updateApplication(dto));
  }

  void remove(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyResult(res, applications.deleteApplication(identity(req).tenantId,
        ApplicationId(param(req, "id")))));
  }

  void rotateSecret(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto who = identity(req);
      replyResult(res, applications.rotateClientSecret(who.tenantId, ApplicationId(param(req, "id")), who.userId));
    });
  }
}
