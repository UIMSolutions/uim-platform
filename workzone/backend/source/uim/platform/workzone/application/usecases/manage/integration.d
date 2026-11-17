/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.integration;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: UI integration cards. Titles are unique; cards shown by widgets
/// can neither be deleted nor deactivated.
class ManageCardsUseCase : ResourceUseCase!(Card, CardId, CreateCardRequest, UpdateCardRequest), IManageCardsUseCase {
  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.cards, publisher, "Card", "workzone.card");
  }

  override protected Card build(CreateCardRequest r) {
    auto c = Card(r.tenantId);
    assignMatching(c, r.spec);
    check(c);
    return c;
  }

  override protected void apply(ref Card c, CardSpec spec) {
    assignMatching(c, spec);
    check(c);
  }

  protected void check(ref Card c) {
    c.title = c.title.strip;
    validateDisplayName("Card title", c.title, 120);
    ensureUnique(repos.cards.findByName(c.tenantId, c.title), c);
    validate(c.dataSourceUrl.length == 0 || isLaunchTarget(c.dataSourceUrl), "Data source '" ~ c.dataSourceUrl
        ~ "' must be an http(s) URL or a relative service path");
    c.dataSourceMethod = c.dataSourceMethod.strip.toUpper;
    validate(["GET", "POST"].canFind(c.dataSourceMethod), "Data source method must be GET or POST");
    validate(["none", "bearer", "basic", "oauth2"].canFind(c.authType), "Unsupported auth type '" ~ c.authType ~ "'");
    validate(c.authType == "none" || c.authToken.length > 0, "Auth type " ~ c.authType ~ " needs a token");
    validate(c.refreshIntervalSec == 0 || c.refreshIntervalSec >= 30, "Refresh interval must be 0 (off) or at least 30 seconds");
    validate(c.maxItems > 0 && c.maxItems <= 100, "Max items must be between 1 and 100");
    if (c.headerTitle.length == 0)
      c.headerTitle = c.title;
    c.allowedRoles = requireRoles(c.tenantId, c.allowedRoles);
  }

  protected PageWidget[] usedBy(const Card c) {
    auto id = c.id;
    return repos.widgets.findMatching(c.tenantId, (const PageWidget w) => w.cardId == id);
  }

  override protected void beforeRemove(Card c) {
    auto users = usedBy(c);
    ensureState(users.length == 0, "Card '" ~ c.title ~ "' is shown by widget(s) on " ~ users.map!(w => w.workpageTitle)
        .array.normalizedNames.join(", "));
  }

  UsecaseResult activate(TenantId tenantId, CardId id, UserId actor) {
    return transition(tenantId, id, actor, "activated", (ref Card c) {
      ensureState(!c.active, "Card '" ~ c.title ~ "' is already active");
      c.active = true;
    });
  }

  UsecaseResult deactivate(TenantId tenantId, CardId id, UserId actor) {
    return transition(tenantId, id, actor, "deactivated", (ref Card c) {
      ensureState(c.active, "Card '" ~ c.title ~ "' is already inactive");
      ensureState(usedBy(c).length == 0, "Card '" ~ c.title ~ "' is shown by widgets — remove them first");
      c.active = false;
    });
  }
}

/// Interactor: business apps. Names are unique; apps used by widgets or
/// navigation entries cannot be deleted; deprecated apps cannot be placed.
class ManageAppsUseCase
  : ResourceUseCase!(AppRegistration, AppId, CreateAppRequest, UpdateAppRequest), IManageAppsUseCase {

  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.apps, publisher, "App", "workzone.app");
  }

  override protected AppRegistration build(CreateAppRequest r) {
    auto a = AppRegistration(r.tenantId);
    assignMatching(a, r.spec);
    check(a);
    return a;
  }

  override protected void apply(ref AppRegistration a, AppSpec spec) {
    assignMatching(a, spec);
    check(a);
  }

  protected void check(ref AppRegistration a) {
    a.name = a.name.strip;
    validateDisplayName("App name", a.name, 120);
    ensureUnique(repos.apps.findByName(a.tenantId, a.name), a);
    validate(isLaunchTarget(a.launchUrl), "Launch URL '" ~ a.launchUrl ~ "' must be an http(s) URL or a relative path");
    validateOptionalUrl("Auth endpoint", a.authEndpoint);
    validate(a.odataServiceUrl.length == 0 || isLaunchTarget(a.odataServiceUrl), "OData service URL '" ~ a.odataServiceUrl ~ "' is invalid");
    validate(["none", "saml", "oauth2", "basic"].canFind(a.authType), "Unsupported auth type '" ~ a.authType ~ "'");
    validate(!a.enableSso || a.authType == "saml" || a.authType == "oauth2", "Single sign-on needs SAML or OAuth2");
    if (a.supportedPlatforms.length == 0)
      a.supportedPlatforms = [AppPlatform.web];
    a.tags = normalizedNames(a.tags);
    a.allowedRoles = requireRoles(a.tenantId, a.allowedRoles);
  }

  override protected void beforeRemove(AppRegistration a) {
    auto id = a.id;
    auto widgets = repos.widgets.findMatching(a.tenantId, (const PageWidget w) => w.appId == id);
    ensureState(widgets.length == 0, "App '" ~ a.name ~ "' is placed in " ~ widgets.length.to!string ~ " widget(s)");
    auto nav = repos.navigationItems.findMatching(a.tenantId, (const NavigationItem n) => n.targetAppId == id);
    ensureState(nav.length == 0, "App '" ~ a.name ~ "' is linked by navigation item(s) " ~ nav.map!(n => n.title).join(", "));
  }

  UsecaseResult activate(TenantId tenantId, AppId id, UserId actor) {
    return transition(tenantId, id, actor, "activated", (ref AppRegistration a) {
      ensureState(a.status != AppStatus.active, "App '" ~ a.name ~ "' is already active");
      a.status = AppStatus.active;
    });
  }

  UsecaseResult deactivate(TenantId tenantId, AppId id, UserId actor) {
    return transition(tenantId, id, actor, "deactivated", (ref AppRegistration a) {
      ensureState(a.status == AppStatus.active, "App '" ~ a.name ~ "' is not active");
      a.status = AppStatus.inactive;
    });
  }

  UsecaseResult deprecate(TenantId tenantId, AppId id, UserId actor) {
    return transition(tenantId, id, actor, "deprecated", (ref AppRegistration a) {
      ensureState(a.status != AppStatus.deprecated_, "App '" ~ a.name ~ "' is already deprecated");
      a.status = AppStatus.deprecated_;
    });
  }
}

/// Interactor: external content providers. Connection tests and syncs run
/// through the content provider gateway.
class ManageContentProvidersUseCase
  : ResourceUseCase!(ExternalContentProvider, ExternalContentProviderId, CreateProviderRequest, UpdateProviderRequest),
  IManageContentProvidersUseCase {

  protected IContentProviderGateway gateway;

  this(WorkzoneRepositories repos, IContentProviderGateway gateway, IWorkzoneEventPublisher publisher) {
    super(repos, repos.contentProviders, publisher, "Content provider", "workzone.content-provider");
    this.gateway = gateway;
  }

  override protected ExternalContentProvider build(CreateProviderRequest r) {
    auto p = ExternalContentProvider(r.tenantId);
    assignMatching(p, r.spec);
    check(p);
    return p;
  }

  override protected void apply(ref ExternalContentProvider p, ProviderSpec spec) {
    auto endpoint = p.endpointUrl;
    assignMatching(p, spec);
    check(p);
    if (p.endpointUrl != endpoint && p.status == ProviderStatus.connected) {
      p.status = ProviderStatus.disconnected; // a new endpoint must be connected again
      p.statusMessage = "Endpoint changed — connect again";
    }
  }

  protected void check(ref ExternalContentProvider p) {
    p.name = p.name.strip;
    validateDisplayName("Provider name", p.name, 120);
    ensureUnique(repos.contentProviders.findByName(p.tenantId, p.name), p);
    validate(isHttpUrl(p.endpointUrl), "Endpoint '" ~ p.endpointUrl ~ "' must be an http(s) URL");
    validate(["none", "bearer", "basic", "oauth2"].canFind(p.authType), "Unsupported auth type '" ~ p.authType ~ "'");
    validate(p.authType == "none" || p.authConfig.length > 0, "Auth type " ~ p.authType ~ " needs credentials (authConfig)");
    validate(p.refreshIntervalSec == 0 || p.refreshIntervalSec >= 60, "Refresh interval must be 0 (manual) or at least 60 seconds");
    p.contentTypes = normalizedNames(p.contentTypes);
  }

  UsecaseResult connect(TenantId tenantId, ExternalContentProviderId id, UserId actor) {
    return transition(tenantId, id, actor, "connected", (ref ExternalContentProvider p) {
      ensureState(p.status != ProviderStatus.connected, "Content provider '" ~ p.name ~ "' is already connected");
      auto outcome = gateway.connect(p);
      if (!outcome.ok) {
        p.status = ProviderStatus.error;
        p.statusMessage = outcome.error;
        return;
      }
      p.status = ProviderStatus.connected;
      p.statusMessage = outcome.message;
    });
  }

  UsecaseResult disconnect(TenantId tenantId, ExternalContentProviderId id, UserId actor) {
    return transition(tenantId, id, actor, "disconnected", (ref ExternalContentProvider p) {
      ensureState(p.status != ProviderStatus.disconnected, "Content provider '" ~ p.name ~ "' is not connected");
      p.status = ProviderStatus.disconnected;
      p.statusMessage = "";
    });
  }

  UsecaseResult sync(TenantId tenantId, ExternalContentProviderId id, UserId actor) {
    return transition(tenantId, id, actor, "synchronised", (ref ExternalContentProvider p) {
      ensureState(p.status == ProviderStatus.connected, "Connect content provider '" ~ p.name ~ "' first");
      applySync(p, gateway.sync(p), nowStdTime());
    });
  }
}

/// Apply the outcome of a sync to a provider (shared with housekeeping).
void applySync(ref ExternalContentProvider p, ProviderOutcome outcome, long now) {
  if (!outcome.ok) {
    p.status = ProviderStatus.error;
    p.statusMessage = outcome.error;
    return;
  }
  p.itemCount = outcome.itemCount;
  p.lastSyncAt = now;
  p.statusMessage = outcome.message;
}

/// Interactor: shell plugins. Assigned sites must exist; active plugins need a
/// script and at least one hook point.
class ManageShellPluginsUseCase
  : ResourceUseCase!(ShellPlugin, ShellPluginId, CreatePluginRequest, UpdatePluginRequest), IManageShellPluginsUseCase {

  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.shellPlugins, publisher, "Shell plugin", "workzone.shell-plugin");
  }

  override protected ShellPlugin build(CreatePluginRequest r) {
    auto p = ShellPlugin(r.tenantId);
    assignMatching(p, r.spec);
    p.installedAt = p.createdAt;
    check(p);
    return p;
  }

  override protected void apply(ref ShellPlugin p, PluginSpec spec) {
    assignMatching(p, spec);
    check(p);
  }

  protected void check(ref ShellPlugin p) {
    p.name = p.name.strip;
    validateDisplayName("Plugin name", p.name, 120);
    ensureUnique(repos.shellPlugins.findByName(p.tenantId, p.name), p);
    validate(p.scriptUrl.length == 0 || isLaunchTarget(p.scriptUrl), "Script '" ~ p.scriptUrl ~ "' must be an http(s) URL or a relative path");
    validateOptionalUrl("Config schema URL", p.configSchemaUrl);
    p.assignedSites = normalizedNames(p.assignedSites);
    foreach (s; p.assignedSites)
      ensureFound(!repos.sites.findByName(p.tenantId, s).isNull, "Site '" ~ s ~ "' not found");
    if (p.status == PluginStatus.active)
      checkActivatable(p);
  }

  protected static void checkActivatable(const ShellPlugin p) {
    validate(p.scriptUrl.length > 0, "Plugin '" ~ p.name ~ "' needs a script URL");
    validate(p.hookPoints.length > 0, "Plugin '" ~ p.name ~ "' needs at least one hook point");
  }

  UsecaseResult activate(TenantId tenantId, ShellPluginId id, UserId actor) {
    return transition(tenantId, id, actor, "activated", (ref ShellPlugin p) {
      ensureState(p.status != PluginStatus.active, "Plugin '" ~ p.name ~ "' is already active");
      checkActivatable(p);
      p.status = PluginStatus.active;
    });
  }

  UsecaseResult deactivate(TenantId tenantId, ShellPluginId id, UserId actor) {
    return transition(tenantId, id, actor, "deactivated", (ref ShellPlugin p) {
      ensureState(p.status != PluginStatus.inactive, "Plugin '" ~ p.name ~ "' is already inactive");
      p.status = PluginStatus.inactive;
    });
  }
}
