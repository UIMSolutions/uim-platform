/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST adapter for authorization policies:
///   GET/POST {api}/policies[?application=]   GET/PUT/PATCH/DELETE {api}/policies/:id
///   POST {api}/policies/evaluate {"applicationId","userId","ipAddress"?,"authMethod"?,"mfaUsed"?}
module uim.platform.identity_authentication.presentation.http.controllers.policies;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class PolicyController : IdentityHttpController {
  protected IManagePoliciesUseCase policies;

  this(IManagePoliciesUseCase policies, string apiPath = "/api/v1", string defaultTenant = "default",
      ITokenService verifier = null) {
    super(apiPath, "policies", defaultTenant, verifier);
    this.policies = policies;
  }

  override void registerRoutes(URLRouter router) {
    router.post(basePath ~ "/evaluate", &evaluate);
    crudRoutes(router, &list, &get, &create, &update, &remove);
  }

  void list(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto t = identity(req).tenantId;
      auto app = query(req, "application");
      replyList(res, app.length ? policies.listByApplication(t, ApplicationId(app)) : policies.listPolicies(t), "Policies");
    });
  }

  void get(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto id = param(req, "id");
      replyOne(res, policies.getPolicy(identity(req).tenantId, PolicyId(id)), "Policy", id);
    });
  }

  void create(HTTPServerRequest req, HTTPServerResponse res) {
    createWith!PolicyDTO(req, res, (dto) => policies.createPolicy(dto));
  }

  void update(HTTPServerRequest req, HTTPServerResponse res) {
    mergeWith!(PolicyDTO, AuthorizationPolicy)(req, res, "Policy", (t, id) => policies.getPolicy(t, PolicyId(id)),
      (dto) => policies.updatePolicy(dto));
  }

  void remove(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyResult(res, policies.deletePolicy(identity(req).tenantId, PolicyId(param(req, "id")))));
  }

  void evaluate(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto b = body(req);
      PolicyEvaluationContext ctx;
      ctx.ipAddress = stringOf(b, "ipAddress");
      ctx.authMethod = parseEnum!AuthMethod(stringOf(b, "authMethod"), AuthMethod.form);
      readBool(b, "mfaUsed", ctx.mfaUsed);
      replyResult(res, policies.evaluateAccess(identity(req).tenantId, ApplicationId(stringOf(b, "applicationId")),
        UserId(stringOf(b, "userId")), ctx));
    });
  }
}
