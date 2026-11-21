/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the ML catalog: scenarios, executables, configurations, artifacts.
/// List operations take an empty resource group id to mean "all groups".
module uim.platform.ai_core.ports.usecases.catalog;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

interface IManageScenarios {
  Scenario createScenario(CreateScenarioRequest r);
  Scenario updateScenario(UpdateScenarioRequest r);
  Scenario getScenario(TenantId t, ResourceGroupId rg, ScenarioId id);
  Scenario[] listScenarios(TenantId t, ResourceGroupId rg);
  /// Refused while executables, configurations or artifacts reference it.
  void deleteScenario(TenantId t, ResourceGroupId rg, ScenarioId id);
}

interface IManageExecutables {
  Executable createExecutable(CreateExecutableRequest r);
  Executable updateExecutable(UpdateExecutableRequest r);
  Executable getExecutable(TenantId t, ResourceGroupId rg, ExecutableId id);
  Executable[] listExecutables(TenantId t, ResourceGroupId rg, ScenarioId scenario = ScenarioId.init);
  /// Refused while configurations reference it.
  void deleteExecutable(TenantId t, ResourceGroupId rg, ExecutableId id);
}

interface IManageConfigurations {
  Configuration createConfiguration(CreateConfigurationRequest r);
  Configuration getConfiguration(TenantId t, ResourceGroupId rg, ConfigurationId id);
  Configuration[] listConfigurations(TenantId t, ResourceGroupId rg, ConfigurationFilter filter = ConfigurationFilter.init);
  /// Refused while executions, deployments or schedules reference it.
  void deleteConfiguration(TenantId t, ResourceGroupId rg, ConfigurationId id);
}

interface IManageArtifacts {
  Artifact createArtifact(CreateArtifactRequest r);
  Artifact updateArtifact(UpdateArtifactRequest r);
  Artifact getArtifact(TenantId t, ResourceGroupId rg, ArtifactId id);
  Artifact[] listArtifacts(TenantId t, ResourceGroupId rg, ArtifactFilter filter = ArtifactFilter.init);
  /// Refused while a configuration binds it.
  void deleteArtifact(TenantId t, ResourceGroupId rg, ArtifactId id);
}
