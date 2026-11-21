/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.configurations;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ManageConfigurationsUseCase : AiCoreInteractor, IManageConfigurations {
  this(AiCoreRepositories repos, IClock clock, IAiCoreEventPublisher events, LifecyclePolicy policy) {
    super(repos, clock, events, policy);
  }

  Configuration createConfiguration(CreateConfigurationRequest r) {
    auto t = r.tenantId, rg = r.resourceGroupId;
    groupOf(t, rg);
    auto scenario = scenarioOf(t, rg, ScenarioId(r.scenarioId.strip));
    auto executable = executableOf(t, rg, ExecutableId(r.executableId.strip));
    if (executable.scenarioId != scenario.id)
      throw AiCoreException.invalid("Executable '" ~ executable.id.value ~ "' does not belong to scenario '" ~ scenario.id.value ~ "'");
    auto id = idOrNew(r.id);
    if (repos.configurations.existsById(t, rg, ConfigurationId(id)))
      throw AiCoreException.conflict("Configuration '" ~ id ~ "' already exists");

    auto bindings = checkedLabels(r.parameterBindings);
    checkParameterBindings(executable, bindings);
    checkArtifactBindings(executable, r.inputArtifactBindings, (ArtifactId a) => repos.artifacts.findById(t, rg, a));

    Configuration c;
    stampCreated!(Configuration, ConfigurationId)(c, t, r.actor, id, now);
    c.resourceGroupId = rg;
    c.scenarioId = scenario.id;
    c.executableId = executable.id;
    c.name = r.name.strip;
    c.parameterBindings = bindings;
    c.inputArtifactBindings = r.inputArtifactBindings.dup;
    c.validate();
    repos.configurations.save(c);
    emit("configuration.created", t, resourceKey(rg.value, id), Json(["executableId": Json(executable.id.value)]));
    return c;
  }

  Configuration getConfiguration(TenantId t, ResourceGroupId rg, ConfigurationId id) {
    return configurationOf(t, rg, id);
  }

  Configuration[] listConfigurations(TenantId t, ResourceGroupId rg, ConfigurationFilter filter = ConfigurationFilter.init) {
    return repos.configurations.findByGroup(t, rg).filter!(c => filter.matches(c)).array;
  }

  void deleteConfiguration(TenantId t, ResourceGroupId rg, ConfigurationId id) {
    configurationOf(t, rg, id);
    auto executions = repos.executions.findByConfiguration(t, rg, id).length;
    auto deployments = repos.deployments.findByConfiguration(t, rg, id).length;
    auto schedules = repos.schedules.findByConfiguration(t, rg, id).length;
    if (executions + deployments + schedules > 0)
      throw AiCoreException.ruleViolation(format("Configuration '%s' is referenced by %d execution(s), %d deployment(s) and %d schedule(s)",
          id.value, executions, deployments, schedules));
    repos.configurations.removeById(t, rg, id);
    emit("configuration.deleted", t, resourceKey(rg.value, id.value));
  }
}
