/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.service_bindings;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Interactor: RAP service bindings. Created unpublished; published bindings
/// must be unpublished before they can be deleted.
class ManageServiceBindingsUseCase
  : ResourceUseCase!(ServiceBinding, ServiceBindingId, CreateServiceBindingRequest, UpdateServiceBindingRequest),
  IManageServiceBindingsUseCase {

  this(AbapRepositories repos, IAbapEventPublisher publisher) {
    super(repos, repos.serviceBindings, publisher, "Service binding", "abap.service-binding");
  }

  override protected ServiceBinding build(CreateServiceBindingRequest r) {
    auto system = requireActiveSystem(r.tenantId, r.parentId, "create service bindings");
    auto b = ServiceBinding(r.tenantId);
    b.systemInstanceId = system.id;
    b.systemName = system.name;
    assignMatching(b, r.spec);
    b.name = b.name.strip.toUpper;
    check(b);
    ensureUnique(repos.serviceBindings.findByName(r.tenantId, system.id, b.name), b, "system '" ~ system.name ~ "'");
    b.status = BindingStatus.unpublished;
    return b;
  }

  override protected void apply(ref ServiceBinding b, ServiceBindingSpec spec) {
    if (spec.bindingType != b.bindingType || spec.serviceDefinition.strip.toUpper != b.serviceDefinition)
      ensureState(b.status == BindingStatus.unpublished,
        "Unpublish service binding '" ~ b.name ~ "' before changing its type or service definition");
    assignMatching(b, spec, ["name"]);
    check(b);
  }

  protected static void check(ref ServiceBinding b) {
    b.serviceDefinition = b.serviceDefinition.strip.toUpper;
    validateAbapName("Service binding", b.name, 26);
    validateAbapName("Service definition", b.serviceDefinition, 30);
    validate(b.serviceVersion.length == 4 && b.serviceVersion.all!(c => c >= '0' && c <= '9'),
      "Service version looks like 0001");
    foreach (e; b.endpoints)
      validate(e.path.startsWith("/"), "Endpoint path '" ~ e.path ~ "' must start with /");
    b.serviceUrl = bindingServiceUrl(b.bindingType, b.serviceDefinition, b.name, b.serviceVersion);
    b.metadataUrl = bindingMetadataUrl(b.bindingType, b.serviceUrl);
  }

  override protected void beforeRemove(ServiceBinding b) {
    ensureState(b.status != BindingStatus.published, "Unpublish service binding '" ~ b.name ~ "' before deleting it");
  }

  UsecaseResult publish(TenantId tenantId, ServiceBindingId id, UserId actor) {
    return transition(tenantId, id, actor, "published", (ref ServiceBinding b) {
      requireActive(requireSystem(tenantId, b.systemInstanceId), "publish services");
      ensureState(b.status != BindingStatus.published, "Service binding '" ~ b.name ~ "' is already published");
      b.status = BindingStatus.published;
      b.publishedAt = nowStdTime();
    });
  }

  UsecaseResult unpublish(TenantId tenantId, ServiceBindingId id, UserId actor) {
    return transition(tenantId, id, actor, "unpublished", (ref ServiceBinding b) {
      ensureState(b.status != BindingStatus.unpublished, "Service binding '" ~ b.name ~ "' is not published");
      b.status = BindingStatus.unpublished;
      b.publishedAt = 0;
    });
  }

  UsecaseResult deprecate(TenantId tenantId, ServiceBindingId id, UserId actor) {
    return transition(tenantId, id, actor, "deprecated", (ref ServiceBinding b) {
      ensureState(b.status == BindingStatus.published, "Only published service bindings can be deprecated");
      b.status = BindingStatus.deprecated_;
    });
  }
}
