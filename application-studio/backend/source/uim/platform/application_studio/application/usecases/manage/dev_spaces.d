/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.dev_spaces;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Interactor: dev spaces. Starts, stops, resumes and deletions are requested
/// here and completed asynchronously by the reconciler.
class ManageDevSpacesUseCase
  : ResourceUseCase!(DevSpace, DevSpaceId, CreateDevSpaceRequest, UpdateDevSpaceRequest),
  IManageDevSpacesUseCase {

  this(StudioRepositories repos, IStudioEventPublisher publisher) {
    super(repos, repos.devSpaces, publisher, "Dev space", "studio.dev-space");
  }

  override protected DevSpace build(CreateDevSpaceRequest r) {
    auto ds = DevSpace(r.tenantId);
    assignMatching(ds, r.spec);
    validateDevSpaceName(ds.name);
    validateEmail("Owner", ds.owner);
    validate(ds.region.strip.length > 0, "Region is required");
    ensureUnique(repos.devSpaces.findByName(r.tenantId, ds.name), ds, "this tenant");

    auto type = requireType(r.tenantId, ds.devSpaceTypeId);
    ds.devSpaceTypeName = type.name;
    ds.extensions = resolveAdditional(type, ds.extensions);
    validateSizing(ds);

    auto samePlan = repos.devSpaces.findByTenant(r.tenantId).filter!(o => o.plan == ds.plan).array;
    ensureCapacity(ds.plan, samePlan.length);
    ensureRunSlot(ds.plan, samePlan.count!(o => o.status.occupiesCompute));

    ds.status = DevSpaceStatus.starting;
    ds.statusMessage = "Start requested";
    return ds;
  }

  /// Name, type and plan are fixed. Extensions and sizes change only while the
  /// dev space does not run (stopped, hibernated or failed).
  override protected void apply(ref DevSpace ds, DevSpaceSpec spec) {
    ensureState(!ds.status.isTransitional, "Dev space '" ~ ds.name ~ "' is " ~ enumText(ds.status) ~ " — try again later");
    auto type = requireType(ds.tenantId, ds.devSpaceTypeId);
    auto extensions = resolveAdditional(type, spec.extensions);
    auto reconfigured = extensions != ds.extensions || spec.memoryLimitMb != ds.memoryLimitMb
      || spec.diskLimitGb != ds.diskLimitGb;
    if (reconfigured)
      ensureState(!ds.status.occupiesCompute, "Stop dev space '" ~ ds.name ~ "' before changing its extensions or sizes");
    assignMatching(ds, spec, ["name", "devSpaceTypeId", "plan", "extensions"]);
    if (reconfigured)
      checkExtensionsStillCover(ds, effectiveExtensions(type, ds), effectiveExtensions(type, withExtensions(ds, extensions)));
    ds.extensions = extensions;
    validateEmail("Owner", ds.owner);
    validate(ds.region.strip.length > 0, "Region is required");
    validateSizing(ds);
  }

  /// Additional extensions: normalised, active, dependencies added, minus the type's predefined ones.
  protected string[] resolveAdditional(const DevSpaceType type, const string[] requested) {
    auto names = normalizedNames(requested);
    requireExtensions(type.tenantId, names, true);
    auto tenant = type.tenantId;
    auto closure = withDependencies(names, (n) => repos.extensions.findByName(tenant, n));
    requireExtensions(type.tenantId, closure, false); // dependencies must exist
    return closure.filter!(n => !type.predefinedExtensions.canFind(n)).array;
  }

  protected static DevSpace withExtensions(DevSpace ds, string[] extensions) {
    ds.extensions = extensions;
    return ds;
  }

  /// Extensions required by the templates of existing projects must remain installed.
  protected void checkExtensionsStillCover(const DevSpace ds, const string[] before, const string[] after) {
    foreach (p; repos.projects.findByDevSpace(ds.tenantId, ds.id)) {
      if (p.templateId.isEmpty)
        continue;
      auto t = repos.projectTemplates.findById(ds.tenantId, p.templateId);
      if (t.isNull)
        continue;
      auto missing = missingNames(t.requiredExtensions, after);
      ensureState(missing.length == 0, "Project '" ~ p.name ~ "' needs extension(s) " ~ missing.join(", ")
          ~ " (template " ~ t.name ~ ")");
    }
  }

  override protected void beforeRemove(DevSpace ds) {
    ensureState(canTransition(ds.status, DevSpaceStatus.deleting), "Dev space '" ~ ds.name
        ~ "' cannot be deleted while " ~ enumText(ds.status) ~ (ds.status.occupiesCompute ? " — stop it first" : ""));
  }

  override protected bool retire(ref DevSpace ds) {
    transitionTo(ds, DevSpaceStatus.deleting);
    ds.statusMessage = "Deletion requested";
    return true;
  }

  protected void requireRunSlot(const DevSpace ds) {
    auto running = repos.devSpaces.findByTenant(ds.tenantId)
      .count!(o => o.id != ds.id && o.plan == ds.plan && o.status.occupiesCompute);
    ensureRunSlot(ds.plan, running);
  }

  UsecaseResult start(TenantId tenantId, DevSpaceId id, UserId actor) {
    return transition(tenantId, id, actor, "start requested", (ref DevSpace ds) {
      ensureState(ds.status == DevSpaceStatus.stopped || ds.status == DevSpaceStatus.hibernated
        || ds.status == DevSpaceStatus.error, "Dev space '" ~ ds.name ~ "' is " ~ enumText(ds.status));
      requireRunSlot(ds);
      transitionTo(ds, ds.status == DevSpaceStatus.hibernated ? DevSpaceStatus.resuming : DevSpaceStatus.starting);
      ds.statusMessage = "Start requested";
    });
  }

  UsecaseResult stop(TenantId tenantId, DevSpaceId id, UserId actor) {
    return transition(tenantId, id, actor, "stop requested", (ref DevSpace ds) {
      ensureState(ds.status == DevSpaceStatus.running, "Dev space '" ~ ds.name ~ "' is not running ("
          ~ enumText(ds.status) ~ ")");
      transitionTo(ds, DevSpaceStatus.stopping);
      ds.statusMessage = "Stop requested";
    });
  }

  /// Developer activity: postpones hibernation; a hibernated dev space resumes.
  UsecaseResult touch(TenantId tenantId, DevSpaceId id, UserId actor) {
    return transition(tenantId, id, actor, "accessed", (ref DevSpace ds) {
      if (ds.status == DevSpaceStatus.hibernated) {
        requireRunSlot(ds);
        transitionTo(ds, DevSpaceStatus.resuming);
        ds.statusMessage = "Resuming after access";
      } else
        ensureState(ds.status == DevSpaceStatus.running, "Dev space '" ~ ds.name ~ "' is " ~ enumText(ds.status));
      ds.lastAccessedAt = nowStdTime();
    });
  }

  UsecaseResult addExtension(TenantId tenantId, DevSpaceId id, string extension, UserId actor) {
    return transition(tenantId, id, actor, "extension added", (ref DevSpace ds) {
      auto name = extension.strip;
      validate(name.length > 0, "Parameter 'extension' is required");
      ensureState(!ds.status.occupiesCompute && !ds.status.isTransitional,
        "Stop dev space '" ~ ds.name ~ "' before changing its extensions");
      auto type = requireType(tenantId, ds.devSpaceTypeId);
      ensureState(!effectiveExtensions(type, ds).canFind(name), "Dev space '" ~ ds.name ~ "' already has '" ~ name ~ "'");
      ds.extensions = resolveAdditional(type, ds.extensions ~ name);
    });
  }

  UsecaseResult removeExtension(TenantId tenantId, DevSpaceId id, string extension, UserId actor) {
    return transition(tenantId, id, actor, "extension removed", (ref DevSpace ds) {
      auto name = extension.strip;
      ensureState(!ds.status.occupiesCompute && !ds.status.isTransitional,
        "Stop dev space '" ~ ds.name ~ "' before changing its extensions");
      auto type = requireType(tenantId, ds.devSpaceTypeId);
      ensureState(!type.predefinedExtensions.canFind(name), "'" ~ name ~ "' is predefined by dev space type "
          ~ type.name ~ " and cannot be removed");
      ensureState(ds.extensions.canFind(name), "Dev space '" ~ ds.name ~ "' has no additional extension '" ~ name ~ "'");
      auto remaining = ds.extensions.filter!(n => n != name).array;
      foreach (other; remaining) {
        auto e = repos.extensions.findByName(tenantId, other);
        ensureState(!e.dependencies.canFind(name), "'" ~ name ~ "' is needed by extension " ~ other);
      }
      checkExtensionsStillCover(ds, effectiveExtensions(type, ds), effectiveExtensions(type, withExtensions(ds, remaining)));
      ds.extensions = remaining;
    });
  }
}
