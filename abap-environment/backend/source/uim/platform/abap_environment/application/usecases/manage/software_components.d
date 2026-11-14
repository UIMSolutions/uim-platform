/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.software_components;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Interactor: software components (gCTS). Clone and pull run asynchronously.
class ManageSoftwareComponentsUseCase
  : ResourceUseCase!(SoftwareComponent, SoftwareComponentId, CreateSoftwareComponentRequest, UpdateSoftwareComponentRequest),
  IManageSoftwareComponentsUseCase {

  this(AbapRepositories repos, IAbapEventPublisher publisher) {
    super(repos, repos.softwareComponents, publisher, "Software component", "abap.software-component");
  }

  override protected SoftwareComponent build(CreateSoftwareComponentRequest r) {
    auto system = requireActiveSystem(r.tenantId, r.parentId, "add software components");
    auto c = SoftwareComponent(r.tenantId);
    c.systemInstanceId = system.id;
    c.systemName = system.name;
    assignMatching(c, r.spec);
    c.name = c.name.strip.toUpper;
    c.namespace = c.namespace.strip.toUpper;
    check(c);
    ensureUnique(repos.softwareComponents.findByName(r.tenantId, system.id, c.name), c, "system '" ~ system.name ~ "'");
    c.status = ComponentStatus.notCloned;
    return c;
  }

  /// The branch changes via checkout; the repository only before the first clone.
  override protected void apply(ref SoftwareComponent c, SoftwareComponentSpec spec) {
    ensureState(c.status != ComponentStatus.cloning && c.status != ComponentStatus.pulling,
      "Software component '" ~ c.name ~ "' is busy (" ~ enumText(c.status) ~ ")");
    if (spec.repositoryUrl != c.repositoryUrl)
      ensureState(c.status == ComponentStatus.notCloned || c.status == ComponentStatus.error,
        "The repository of a cloned software component cannot be changed");
    assignMatching(c, spec, ["name", "branch"]);
    c.namespace = c.namespace.strip.toUpper;
    check(c);
  }

  protected static void check(const ref SoftwareComponent c) {
    validateAbapName("Software component", c.name, 30);
    validate(isHttpUrl(c.repositoryUrl), "Repository URL must be an http(s) URL");
    validate(c.branch.strip.length > 0, "Branch is required");
    if (c.namespace.length > 0) {
      validate(c.namespace.length >= 3 && c.namespace[0] == '/' && c.namespace[$ - 1] == '/',
        "Namespace looks like /DMO/");
      validate(c.name.startsWith(c.namespace), "Software component '" ~ c.name ~ "' must use namespace " ~ c.namespace);
    }
  }

  override protected void beforeRemove(SoftwareComponent c) {
    ensureState(c.status != ComponentStatus.cloning && c.status != ComponentStatus.pulling,
      "Software component '" ~ c.name ~ "' is busy (" ~ enumText(c.status) ~ ")");
  }

  UsecaseResult clone(TenantId tenantId, SoftwareComponentId id, UserId actor) {
    return transition(tenantId, id, actor, "clone started", (ref SoftwareComponent c) {
      requireActive(requireSystem(tenantId, c.systemInstanceId), "clone software components");
      ensureState(c.status == ComponentStatus.notCloned || c.status == ComponentStatus.error,
        "Software component '" ~ c.name ~ "' is already cloned");
      c.status = ComponentStatus.cloning;
      c.clonedBy = actor;
      c.statusMessage = "Cloning branch " ~ c.branch;
    });
  }

  UsecaseResult pull(TenantId tenantId, SoftwareComponentId id, UserId actor) {
    return transition(tenantId, id, actor, "pull started", (ref SoftwareComponent c) {
      requireActive(requireSystem(tenantId, c.systemInstanceId), "pull software components");
      ensureState(c.status == ComponentStatus.cloned, "Software component '" ~ c.name ~ "' must be cloned before pulling");
      c.status = ComponentStatus.pulling;
      c.statusMessage = "Pulling branch " ~ c.branch;
    });
  }

  UsecaseResult checkout(TenantId tenantId, SoftwareComponentId id, string branch, UserId actor) {
    return transition(tenantId, id, actor, "checkout started", (ref SoftwareComponent c) {
      auto b = branch.strip;
      validate(b.length > 0, "Branch is required");
      ensureState(c.status == ComponentStatus.cloned, "Software component '" ~ c.name ~ "' must be cloned before a checkout");
      c.branch = b;
      c.status = ComponentStatus.pulling;
      c.statusMessage = "Checking out branch " ~ b;
    });
  }
}
