/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST adapter for risk-based authentication rules:
///   GET/POST {api}/risk-rules   GET/PUT/PATCH/DELETE {api}/risk-rules/:id
///   POST {api}/risk-rules/assess {"userId","ipAddress"?,"userAgent"?,"authMethod"?}
module uim.platform.identity_authentication.presentation.http.controllers.risk_rules;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class RiskRuleController : IdentityHttpController {
  protected IManageRiskRulesUseCase rules;

  this(IManageRiskRulesUseCase rules, string apiPath = "/api/v1", string defaultTenant = "default",
      ITokenService verifier = null) {
    super(apiPath, "risk-rules", defaultTenant, verifier);
    this.rules = rules;
  }

  override void registerRoutes(URLRouter router) {
    router.post(basePath ~ "/assess", &assess);
    crudRoutes(router, &list, &get, &create, &update, &remove);
  }

  void list(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyList(res, rules.listRiskRules(identity(req).tenantId), "Risk rules"));
  }

  void get(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto id = param(req, "id");
      replyOne(res, rules.getRiskRule(identity(req).tenantId, RiskRuleId(id)), "Risk rule", id);
    });
  }

  void create(HTTPServerRequest req, HTTPServerResponse res) {
    createWith!RiskRuleDTO(req, res, (dto) => rules.createRiskRule(dto));
  }

  void update(HTTPServerRequest req, HTTPServerResponse res) {
    mergeWith!(RiskRuleDTO, RiskRule)(req, res, "Risk rule", (t, id) => rules.getRiskRule(t, RiskRuleId(id)),
      (dto) => rules.updateRiskRule(dto));
  }

  void remove(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyResult(res, rules.deleteRiskRule(identity(req).tenantId, RiskRuleId(param(req, "id")))));
  }

  void assess(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto b = body(req);
      RiskEvaluationContext ctx;
      ctx.ipAddress = stringOf(b, "ipAddress");
      ctx.userAgent = stringOf(b, "userAgent");
      ctx.authMethod = parseEnum!AuthMethod(stringOf(b, "authMethod"), AuthMethod.form);
      replyResult(res, rules.assess(identity(req).tenantId, UserId(stringOf(b, "userId")), ctx));
    });
  }
}
