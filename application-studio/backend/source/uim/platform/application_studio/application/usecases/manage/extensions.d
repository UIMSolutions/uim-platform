/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.extensions;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Interactor: extensions of the catalogue. Predefined extensions are part of
/// dev space types and cannot be changed, withdrawn or deleted.
class ManageExtensionsUseCase
  : ResourceUseCase!(Extension, ExtensionId, CreateExtensionRequest, UpdateExtensionRequest),
  IManageExtensionsUseCase {

  this(StudioRepositories repos, IStudioEventPublisher publisher) {
    super(repos, repos.extensions, publisher, "Extension", "studio.extension");
  }

  override protected Extension build(CreateExtensionRequest r) {
    auto e = Extension(r.tenantId);
    assignMatching(e, r.spec);
    e.name = e.name.strip;
    validate(e.scope_ != ExtensionScope.predefined, "Scope 'predefined' is reserved for the SAP catalogue");
    check(e);
    ensureUnique(repos.extensions.findByName(r.tenantId, e.name), e, "the catalogue");
    e.status = ExtensionStatus.active;
    return e;
  }

  override protected void apply(ref Extension e, ExtensionSpec spec) {
    requireNotPredefined(e, "changed");
    assignMatching(e, spec, ["name", "scope_"]);
    check(e);
  }

  protected void check(ref Extension e) {
    validateCatalogName("Extension", e.name);
    if (e.displayName.strip.length == 0)
      e.displayName = e.name;
    validateDisplayName("Extension display", e.displayName);
    validateSemVer("Extension", e.version_);
    e.dependencies = normalizedNames(e.dependencies);
    e.capabilities = normalizedNames(e.capabilities);
    validate(!e.dependencies.canFind(e.name), "Extension '" ~ e.name ~ "' cannot depend on itself");
    requireExtensions(e.tenantId, e.dependencies, false);
  }

  protected static void requireNotPredefined(const ref Extension e, string what) {
    ensureState(e.scope_ != ExtensionScope.predefined, "Predefined extension '" ~ e.name ~ "' cannot be " ~ what);
  }

  override protected void beforeRemove(Extension e) {
    requireNotPredefined(e, "deleted");
    auto t = e.tenantId;
    auto spaces = repos.devSpaces.findByExtension(t, e.name);
    ensureState(spaces.length == 0, "Extension '" ~ e.name ~ "' is installed in dev space(s) "
        ~ spaces.map!(d => d.name).join(", "));
    auto types = repos.devSpaceTypes.findByTenant(t).filter!(x => x.predefinedExtensions.canFind(e.name)).array;
    ensureState(types.length == 0, "Extension '" ~ e.name ~ "' is part of dev space type(s) "
        ~ types.map!(x => x.name).join(", "));
    auto templates = repos.projectTemplates.findByTenant(t).filter!(x => x.requiredExtensions.canFind(e.name)).array;
    ensureState(templates.length == 0, "Extension '" ~ e.name ~ "' is required by template(s) "
        ~ templates.map!(x => x.name).join(", "));
    auto dependents = repos.extensions.findByTenant(t).filter!(x => x.dependencies.canFind(e.name)).array;
    ensureState(dependents.length == 0, "Extension '" ~ e.name ~ "' is a dependency of "
        ~ dependents.map!(x => x.name).join(", "));
  }

  UsecaseResult activate(TenantId tenantId, ExtensionId id, UserId actor) {
    return transition(tenantId, id, actor, "activated", (ref Extension e) {
      ensureState(e.status != ExtensionStatus.active, "Extension '" ~ e.name ~ "' is already active");
      e.status = ExtensionStatus.active;
    });
  }

  UsecaseResult deactivate(TenantId tenantId, ExtensionId id, UserId actor) {
    return transition(tenantId, id, actor, "deactivated", (ref Extension e) {
      requireNotPredefined(e, "deactivated");
      ensureState(e.status == ExtensionStatus.active, "Extension '" ~ e.name ~ "' is not active");
      e.status = ExtensionStatus.inactive;
    });
  }

  UsecaseResult deprecate(TenantId tenantId, ExtensionId id, UserId actor) {
    return transition(tenantId, id, actor, "deprecated", (ref Extension e) {
      requireNotPredefined(e, "deprecated");
      ensureState(e.status != ExtensionStatus.deprecated_, "Extension '" ~ e.name ~ "' is already deprecated");
      e.status = ExtensionStatus.deprecated_;
    });
  }
}
