/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.service_bindings;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Interactor: service bindings of a dev space. Connection tests run in the reconciler.
class ManageServiceBindingsUseCase
  : ResourceUseCase!(ServiceBinding, ServiceBindingId, CreateServiceBindingRequest, UpdateServiceBindingRequest),
  IManageServiceBindingsUseCase {

  this(StudioRepositories repos, IStudioEventPublisher publisher) {
    super(repos, repos.serviceBindings, publisher, "Service binding", "studio.service-binding");
  }

  override protected ServiceBinding build(CreateServiceBindingRequest r) {
    auto ds = requireDevSpace(r.tenantId, r.parentId);
    auto b = ServiceBinding(r.tenantId);
    b.devSpaceId = ds.id;
    b.devSpaceName = ds.name;
    assignMatching(b, r.spec);
    check(b);
    ensureUnique(repos.serviceBindings.findByName(r.tenantId, ds.id, b.name), b, "dev space " ~ ds.name);
    b.status = BindingStatus.disconnected;
    return b;
  }

  /// Changing the connection settings disconnects the binding.
  override protected void apply(ref ServiceBinding b, ServiceBindingSpec spec) {
    auto before = [b.systemAlias, b.serviceUrl, b.servicePath, enumText(b.authType), b.user, b.credentials,
      enumText(b.providerType)];
    assignMatching(b, spec, ["name"]);
    check(b);
    auto after = [b.systemAlias, b.serviceUrl, b.servicePath, enumText(b.authType), b.user, b.credentials,
      enumText(b.providerType)];
    if (before != after && b.status != BindingStatus.disconnected) {
      b.status = BindingStatus.disconnected;
      b.statusMessage = "Connection settings changed — connect again";
    }
  }

  protected static void check(ref ServiceBinding b) {
    validateDisplayName("Service binding", b.name);
    b.serviceUrl = b.serviceUrl.strip;
    b.systemAlias = b.systemAlias.strip;
    validate(b.serviceUrl.length > 0 || b.systemAlias.length > 0, "A service URL or a destination (systemAlias) is required");
    validate(b.serviceUrl.length == 0 || isHttpUrl(b.serviceUrl), "Service URL '" ~ b.serviceUrl ~ "' must be an http(s) URL");
    if (b.providerType.isODataProvider) {
      validate(b.servicePath.length > 0, enumText(b.providerType) ~ " bindings need the OData service path");
      validate(b.servicePath.startsWith("/"), "Service path must start with '/'");
    }
    if (b.authType.needsCredentials) {
      validate(b.user.strip.length > 0, enumText(b.authType) ~ " needs a user / client ID");
      validate(b.credentials.length > 0, enumText(b.authType) ~ " needs a password / client secret");
    }
  }

  override protected void beforeRemove(ServiceBinding b) {
    auto users = repos.runConfigurations.findByDevSpace(b.tenantId, b.devSpaceId)
      .filter!(r => r.serviceBindings.canFind(b.name)).array;
    ensureState(users.length == 0, "Service binding '" ~ b.name ~ "' is used by run configuration(s) "
        ~ users.map!(r => r.name).join(", "));
  }

  UsecaseResult connect(TenantId tenantId, ServiceBindingId id, UserId actor) {
    return transition(tenantId, id, actor, "connection requested", (ref ServiceBinding b) {
      ensureState(b.status == BindingStatus.disconnected || b.status == BindingStatus.error,
        "Service binding '" ~ b.name ~ "' is " ~ enumText(b.status));
      requireRunning(requireDevSpace(tenantId, b.devSpaceId), "connect services");
      b.status = BindingStatus.connecting;
      b.statusMessage = "Testing connection";
    });
  }

  UsecaseResult disconnect(TenantId tenantId, ServiceBindingId id, UserId actor) {
    return transition(tenantId, id, actor, "disconnected", (ref ServiceBinding b) {
      ensureState(b.status != BindingStatus.disconnected, "Service binding '" ~ b.name ~ "' is not connected");
      b.status = BindingStatus.disconnected;
      b.statusMessage = "";
    });
  }
}
