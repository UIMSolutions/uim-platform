/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.usecases.manage.transformations;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Interactor: attribute mappings and entity filters of a system.
class ManageTransformationsUseCase
  : ResourceUseCase!(Transformation, TransformationId, CreateTransformationRequest, UpdateTransformationRequest),
  IManageTransformationsUseCase {

  this(ProvisioningRepositories repos, EventRecorder events) {
    super(repos, repos.transformations, events, "Transformation", "provisioning.transformation");
  }

  override protected Transformation build(CreateTransformationRequest r) {
    auto t = Transformation(r.tenantId);
    assignMatching(t, r.spec);
    check(t);
    return t;
  }

  override protected void apply(ref Transformation t, TransformationSpec spec) {
    assignMatching(t, spec);
    check(t);
  }

  protected void check(ref Transformation t) {
    validateDisplayName(kindLabel, t.name);
    validate(t.sequence >= 0 && t.sequence <= 9999, "Sequence must be between 0 and 9999");
    validate(t.systemId.length > 0, "systemId is required (the " ~ enumText(t.systemRole) ~ " system)");
    t.systemName = systemName(t.tenantId, t.systemRole, t.systemId);
    validateRules(t.mappings, t.conditions);
    ensureUnique(repos.transformations.findByName(t.tenantId, t.name), t, "this tenant");
  }

  /// Name of the referenced system; it must exist in the given role.
  protected string systemName(TenantId tenantId, SystemRole role, string systemId) {
    string name;
    final switch (role) {
    case SystemRole.source:
      name = repos.sourceSystems.findById(tenantId, SourceSystemId(systemId)).name;
      break;
    case SystemRole.target:
      name = repos.targetSystems.findById(tenantId, TargetSystemId(systemId)).name;
      break;
    case SystemRole.proxy:
      name = repos.proxySystems.findById(tenantId, ProxySystemId(systemId)).name;
      break;
    }
    if (name.length == 0)
      throw new ProvisioningNotFoundException(fieldLabel(enumText(role)) ~ " system '" ~ systemId ~ "' not found");
    return name;
  }

  UsecaseResult activate(TenantId tenantId, TransformationId id, UserId actor) {
    return transition(tenantId, id, actor, "activated", (ref t) {
      ensureState(!t.active, "Transformation '" ~ t.name ~ "' is already active");
      t.active = true;
    });
  }

  UsecaseResult deactivate(TenantId tenantId, TransformationId id, UserId actor) {
    return transition(tenantId, id, actor, "deactivated", (ref t) {
      ensureState(t.active, "Transformation '" ~ t.name ~ "' is already inactive");
      t.active = false;
    });
  }

  TransformationPreview preview(TenantId tenantId, TransformationId id, EntityType entityType, Attribute[] sample) {
    auto t = require(tenantId, id);
    auto r = transform(t, entityType, sample);
    TransformationPreview p;
    p.transformationName = t.name;
    p.entityType = entityType;
    p.accepted = r.accepted;
    p.failed = r.failed;
    p.reason = r.reason.length ? r.reason : (t.active ? "" : "transformation is inactive — attributes passed through");
    p.attributes = r.attributes;
    p.checksum = attributeChecksum(r.attributes);
    return p;
  }

  Transformation[] forSystem(TenantId tenantId, SystemRole role, string systemId) {
    auto list = repos.transformations.findBySystem(tenantId, role, systemId);
    list.sort!((a, b) => a.sequence != b.sequence ? a.sequence < b.sequence : a.name < b.name);
    return list;
  }

  Transformation findByName(TenantId tenantId, string name) {
    return repos.transformations.findByName(tenantId, name);
  }
}
