/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.ai_launchpad.ports.repositories.repositories;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IWorkspaceRepository : IAilpRepository!(Workspace, WorkspaceId) {
}

interface IConnectionRepository : IAilpRepository!(Connection, ConnectionId) {
}

interface IResourceGroupRepository : IAilpRepository!(ResourceGroup, ResourceGroupId) {
}

interface IScenarioRepository : IAilpRepository!(Scenario, ScenarioId) {
}

interface IConfigurationRepository : IAilpRepository!(Configuration, ConfigurationId) {
}

interface IExecutionRepository : IAilpRepository!(Execution, ExecutionId) {
}

interface IDeploymentRepository : IAilpRepository!(Deployment, DeploymentId) {
}

interface IModelRepository : IAilpRepository!(Model, ModelId) {
}

interface IDatasetRepository : IAilpRepository!(Dataset, DatasetId) {
}

interface IPromptCollectionRepository : IAilpRepository!(PromptCollection, PromptCollectionId) {
}

interface IPromptRepository : IAilpRepository!(Prompt, PromptId) {
}

interface ITileRepository : IAilpRepository!(Tile, TileId) {
}

interface IRoleRepository : IAilpRepository!(Role, RoleId) {
}

interface IUserAccountRepository : IAilpRepository!(UserAccount, UserAccountId) {
}

interface ILogEntryRepository : IAilpRepository!(LogEntry, LogEntryId) {
  /// Entries created before the cut-off (std time) are removed; returns the count.
  size_t removeBefore(TenantId t, long cutoff);
  /// Number of entries created at or after since (optionally of a minimum severity).
  size_t countSince(TenantId t, long since, bool warningsOnly = false);
}

/// All repositories (passed to the interactors as one bundle).
struct AilpRepositories {
  IWorkspaceRepository workspaces;
  IConnectionRepository connections;
  IResourceGroupRepository resourceGroups;
  IScenarioRepository scenarios;
  IConfigurationRepository configurations;
  IExecutionRepository executions;
  IDeploymentRepository deployments;
  IModelRepository models;
  IDatasetRepository datasets;
  IPromptCollectionRepository promptCollections;
  IPromptRepository prompts;
  ITileRepository tiles;
  IRoleRepository roles;
  IUserAccountRepository users;
  ILogEntryRepository logs;
}
