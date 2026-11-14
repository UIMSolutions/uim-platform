/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.presentation.rest.services;

import vibe.http.common : HTTPStatusException;
import uim.platform.service.presentation.odata;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class AuthorizationRuntimeApi : IAuthorizationRuntimeApi {
  protected ODataEngine engine;
  protected AuthorizationPorts ports;
  protected SecuritySetup security;

  this(ODataEngine engine, AuthorizationPorts ports, SecuritySetup security) {
    this.engine = engine;
    this.ports = ports;
    this.security = security;
  }

  Json check(string principalId, string application, string resource, string action, string[] groups,
    string[string] attributes, string tenantId, string authorization) {
    return guarded(tenantId, authorization, (const RequestContext ctx) {
      auto p = Json.emptyObject;
      p["principalId"] = principalId;
      p["application"] = application;
      p["resource"] = resource;
      p["action"] = action;
      p["groups"] = groups.join(", ");
      p["attributes"] = attributesText(attributes);
      return engine.invoke(ctx, "EvaluateAuthorization", p);
    });
  }

  Json principalPolicies(string _principal, string application, string groups, string tenantId, string authorization) {
    return guarded(tenantId, authorization, (const RequestContext ctx) {
      auto t = tenantOf(ctx);
      ManagedApplicationId appId;
      if (application.length)
        appId = translated!ManagedApplication(() => ports.applications.resolveApplication(t, application)).id;
      auto rows = Json.emptyArray;
      foreach (p; ports.evaluation.effectivePolicies(t, _principal, splitList(groups), appId))
        rows ~= engine.read(ctx, "Policies", p.id.value);
      return Json.emptyObject.set("principalId", _principal).set("count", rows.length).set("policies", rows);
    });
  }

  Json statistics(string tenantId, string authorization) {
    return guarded(tenantId, authorization, (const RequestContext ctx) => engine.read(ctx, "Statistics", ""));
  }

  protected Json guarded(string tenantId, string authorization, scope Json delegate(const RequestContext) @safe dg) {
    auto ctx = resolveRequestContext(authorization, tenantId, "", security.defaultTenant, security.verifier);
    ctx.channel = "rest";
    if (security.requireAuthentication && !ctx.authenticated)
      throw new HTTPStatusException(401, "A valid bearer token is required");
    try
      return dg(ctx);
    catch (EntitySetException e)
      throw new HTTPStatusException(e.status, e.msg);
    catch (AuthorizationException e)
      throw new HTTPStatusException(toEntitySetException(e).status, e.msg);
  }
}
