/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.applications;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Interactor: Application Connectivity (requires the application-connector module).
class ManageApplicationsUseCase
  : ResourceUseCase!(KymaApplication, ApplicationId, RegisterApplicationRequest, UpdateApplicationRequest),
  IManageApplicationsUseCase {

  this(KymaRepositories repos, IKymaEventPublisher publisher, IClusterGateway cluster) {
    super(repos, repos.applications, publisher, cluster, "Application", "kyma.application");
  }

  override protected KymaApplication build(RegisterApplicationRequest r) {
    auto env = requireEnvironment(r.tenantId, r.parentId);
    requireModule(r.tenantId, env.id, WorkloadKind.application);
    auto app = KymaApplication(r.tenantId);
    app.environmentId = env.id;
    assignMatching(app, r.spec);
    check(app);
    ensureState(repos.applications.findByName(r.tenantId, env.id, app.name).isNull,
      "Application '" ~ app.name ~ "' is already registered in environment '" ~ env.name ~ "'");
    app.connectorUrl = "https://gateway." ~ env.shootDomain ~ "/" ~ app.name;
    app.accessLabel = app.name;
    app.status = AppConnectivityStatus.disconnected;
    return app;
  }

  override protected void apply(ref KymaApplication app, ApplicationSpec spec) {
    assignMatching(app, spec, ["name"]);
    check(app);
  }

  protected static void check(const ref KymaApplication app) {
    validateResourceName("Application", app.name);
    if (app.registrationType == AppRegistrationType.api)
      validate(app.events.length == 0, "An API-only application cannot register events");
    if (app.registrationType == AppRegistrationType.events)
      validate(app.apis.length == 0, "An events-only application cannot register APIs");
    foreach (api; app.apis) {
      validate(api.name.length > 0, "Every API needs a name");
      validate(api.targetUrl.startsWith("https://") || api.targetUrl.startsWith("http://"),
        "API '" ~ api.name ~ "' needs an http(s) target URL");
    }
    foreach (e; app.events)
      validate(e.name.length > 0, "Every event needs a name");
  }

  override protected Json render(KymaApplication app) {
    return Json(null);
  }

  UsecaseResult connect(TenantId tenantId, ApplicationId id, UserId actor) {
    return transition(tenantId, id, actor, "connected", (ref KymaApplication app) {
      ensureState(app.status != AppConnectivityStatus.connected && app.status != AppConnectivityStatus.pairing,
        "Application is already " ~ enumText(app.status));
      app.status = AppConnectivityStatus.pairing;
    });
  }

  UsecaseResult disconnect(TenantId tenantId, ApplicationId id, UserId actor) {
    return transition(tenantId, id, actor, "disconnected", (ref KymaApplication app) {
      ensureState(app.status != AppConnectivityStatus.disconnected, "Application is not connected");
      app.status = AppConnectivityStatus.disconnected;
    });
  }

  UsecaseResult bindNamespace(TenantId tenantId, ApplicationId id, string namespaceName, UserId actor) {
    return transition(tenantId, id, actor, "bound to " ~ namespaceName, (ref KymaApplication app) {
      validate(namespaceName.length > 0, "namespace is required");
      auto ns = repos.namespaces.findByName(tenantId, app.environmentId, namespaceName);
      if (ns.isNull)
        throw new KymaNotFoundException("Namespace '" ~ namespaceName ~ "' not found in the application's environment");
      ensureState(!app.boundNamespaces.canFind(namespaceName), "Already bound to '" ~ namespaceName ~ "'");
      app.boundNamespaces ~= namespaceName;
    });
  }

  UsecaseResult unbindNamespace(TenantId tenantId, ApplicationId id, string namespaceName, UserId actor) {
    return transition(tenantId, id, actor, "unbound from " ~ namespaceName, (ref KymaApplication app) {
      ensureState(app.boundNamespaces.canFind(namespaceName), "Not bound to '" ~ namespaceName ~ "'");
      app.boundNamespaces = app.boundNamespaces.filter!(n => n != namespaceName).array;
    });
  }
}
