/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Helpers shared by the interactors.
module uim.platform.ai_core.application.services.support;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// Return the entity or throw notFound.
T required(T)(T entity, lazy string what) {
  if (entity.isNull)
    throw AiCoreException.notFound(what);
  return entity;
}

/// Initialise id, tenant and audit fields of a new entity.
void stampCreated(E, TId)(ref E entity, TenantId tenantId, UserId actor, string id, long now) {
  if (tenantId.isNull)
    throw AiCoreException.invalid("Tenant is required");
  entity.id = TId(id);
  entity.tenantId = tenantId;
  entity.createdAt = now;
  entity.updatedAt = now;
  entity.createdBy = actor;
  entity.updatedBy = actor;
}

/// Refresh the audit fields of a changed entity.
void stampUpdated(E)(ref E entity, UserId actor, long now) {
  entity.updatedAt = now;
  entity.updatedBy = actor;
}

/// Validate labels (throws invalid).
Label[] checkedLabels(const Label[] labels) {
  Label[] result;
  foreach (l; labels) {
    if (!isValidLabel(l))
      throw AiCoreException.invalid("Invalid label key '" ~ l.key ~ "'");
    result = setLabel(result, l.key, l.value);
  }
  return result;
}

/// A requested id, or a generated one. Generated ids never clash with '~'.
string idOrNew(string requested) {
  auto id = requested.strip;
  if (id.length == 0)
    return newResourceId();
  requireResourceId(id, "id");
  return id;
}

/// A new, validated resource group (PROVISIONED at once if the policy has
/// no provisioning delay).
ResourceGroup buildResourceGroup(TenantId t, UserId actor, string id, const Label[] labels, long now, const LifecyclePolicy policy) {
  requireResourceGroupId(id);
  ResourceGroup g;
  stampCreated!(ResourceGroup, ResourceGroupId)(g, t, actor, id, now);
  g.labels = checkedLabels(labels);
  if (policy.provisionSeconds <= 0) {
    g.status = ResourceGroupStatus.provisioned;
    g.statusMessage = "Resource group provisioned";
  } else {
    g.status = ResourceGroupStatus.provisioning;
    g.statusMessage = "Provisioning resource group";
  }
  g.validate();
  return g;
}

/// Base class of all interactors: repositories, clock, events and policy.
abstract class AiCoreInteractor {
  protected AiCoreRepositories repos;
  protected IClock clock;
  protected IAiCoreEventPublisher events;
  protected LifecyclePolicy policy;

  /// Resource group that is created on first use (SAP AI Core always has
  /// "default"); "" disables the implicit creation.
  string defaultGroup = "default";

  this(AiCoreRepositories repos, IClock clock, IAiCoreEventPublisher events, LifecyclePolicy policy) {
    this.repos = repos;
    this.clock = clock;
    this.events = events !is null ? events : new NullEventPublisher;
    this.policy = policy;
  }

  protected long now() {
    return clock.now();
  }

  protected void emit(string type, TenantId t, string subject, Json data = Json.emptyObject) {
    events.publish(type, t, subject, data);
  }

  /// The group must exist (and must not be in status ERROR).
  protected ResourceGroup groupOf(TenantId t, ResourceGroupId rg) {
    if (rg.isNull)
      throw AiCoreException.invalid("Resource group is required (header AI-Resource-Group)");
    auto g = repos.resourceGroups.findById(t, rg);
    if (g.isNull && defaultGroup.length > 0 && rg.value == defaultGroup) {
      g = buildResourceGroup(t, UserId("system"), defaultGroup, null, now, policy);
      repos.resourceGroups.save(g);
      emit("resourceGroup.created", t, defaultGroup, Json(["status": Json(cast(string) g.status)]));
    }
    if (g.isNull)
      throw AiCoreException.notFound("Resource group '" ~ rg.value ~ "'");
    if (g.status == ResourceGroupStatus.error)
      throw AiCoreException.ruleViolation("Resource group '" ~ rg.value ~ "' is in status ERROR");
    return g;
  }

  /// The group must be PROVISIONED (runtime resources need the namespace).
  protected ResourceGroup provisionedGroupOf(TenantId t, ResourceGroupId rg) {
    auto g = groupOf(t, rg);
    if (!g.isProvisioned)
      throw AiCoreException.ruleViolation("Resource group '" ~ rg.value ~ "' is still " ~ cast(string) g.status);
    return g;
  }

  protected Scenario scenarioOf(TenantId t, ResourceGroupId rg, ScenarioId id) {
    return required(repos.scenarios.findById(t, rg, id), "Scenario '" ~ id.value ~ "'");
  }

  protected Executable executableOf(TenantId t, ResourceGroupId rg, ExecutableId id) {
    return required(repos.executables.findById(t, rg, id), "Executable '" ~ id.value ~ "'");
  }

  protected Configuration configurationOf(TenantId t, ResourceGroupId rg, ConfigurationId id) {
    return required(repos.configurations.findById(t, rg, id), "Configuration '" ~ id.value ~ "'");
  }
}

///
unittest {
  assert(checkedLabels([Label("a", "1"), Label("a", "2")]) == [Label("a", "2")]);
  assert(failsWith(AiCoreErrorKind.invalid, () { checkedLabels([Label("bad key", "")]); }));
  assert(idOrNew("").length == 16 && idOrNew("my-id") == "my-id");
  assert(failsWith(AiCoreErrorKind.invalid, () { idOrNew("a~b"); }));
}
