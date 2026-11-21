/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.executables;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ManageExecutablesUseCase : AiCoreInteractor, IManageExecutables {
  this(AiCoreRepositories repos, IClock clock, IAiCoreEventPublisher events, LifecyclePolicy policy) {
    super(repos, clock, events, policy);
  }

  Executable createExecutable(CreateExecutableRequest r) {
    groupOf(r.tenantId, r.resourceGroupId);
    auto scenario = scenarioOf(r.tenantId, r.resourceGroupId, ScenarioId(r.scenarioId.strip));
    auto id = r.id.strip;
    requireResourceId(id, "executable id");
    if (repos.executables.existsById(r.tenantId, r.resourceGroupId, ExecutableId(id)))
      throw AiCoreException.conflict("Executable '" ~ id ~ "' already exists in resource group '" ~ r.resourceGroupId.value ~ "'");
    Executable e;
    stampCreated!(Executable, ExecutableId)(e, r.tenantId, r.actor, id, now);
    e.resourceGroupId = r.resourceGroupId;
    e.scenarioId = scenario.id;
    e.name = r.name.strip.length > 0 ? r.name.strip : id;
    e.description = r.description;
    e.type = parseDomainEnumOr!ExecutableType(r.type, ExecutableType.workflow, "executable type");
    e.versionId = r.versionId.strip.length > 0 ? r.versionId.strip : "1.0.0";
    e.parameters = r.parameters.dup;
    e.inputArtifacts = r.inputArtifacts.dup;
    e.outputArtifacts = r.outputArtifacts.dup;
    e.labels = checkedLabels(r.labels);
    e.validate();
    repos.executables.save(e);
    emit("executable.created", r.tenantId, resourceKey(r.resourceGroupId.value, id), Json(["type": Json(cast(string) e.type)]));
    return e;
  }

  Executable updateExecutable(UpdateExecutableRequest r) {
    auto e = getExecutable(r.tenantId, r.resourceGroupId, ExecutableId(r.id));
    r.name.applyTo(e.name);
    r.description.applyTo(e.description);
    r.versionId.applyTo(e.versionId);
    if (r.parameters.isSet)
      e.parameters = r.parameters.value.dup;
    if (r.inputArtifacts.isSet)
      e.inputArtifacts = r.inputArtifacts.value.dup;
    if (r.outputArtifacts.isSet)
      e.outputArtifacts = r.outputArtifacts.value.dup;
    if (r.labels.isSet)
      e.labels = checkedLabels(r.labels.value);
    e.validate();
    stampUpdated(e, r.actor, now);
    repos.executables.save(e);
    return e;
  }

  Executable getExecutable(TenantId t, ResourceGroupId rg, ExecutableId id) {
    return executableOf(t, rg, id);
  }

  Executable[] listExecutables(TenantId t, ResourceGroupId rg, ScenarioId scenario = ScenarioId.init) {
    auto all = repos.executables.findByGroup(t, rg);
    return scenario.isNull ? all : all.filter!(e => e.scenarioId == scenario).array;
  }

  void deleteExecutable(TenantId t, ResourceGroupId rg, ExecutableId id) {
    executableOf(t, rg, id);
    auto used = repos.configurations.findByExecutable(t, rg, id).length;
    if (used > 0)
      throw AiCoreException.ruleViolation(format("Executable '%s' is used by %d configuration(s)", id.value, used));
    repos.executables.removeById(t, rg, id);
    emit("executable.deleted", t, resourceKey(rg.value, id.value));
  }
}
