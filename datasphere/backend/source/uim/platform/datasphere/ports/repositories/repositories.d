/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.datasphere.ports.repositories.repositories;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

interface ISpaceRepository : IDspRepository!(Space, SpaceId) {
}

interface ISpaceMemberRepository : IDspRepository!(SpaceMember, SpaceMemberId) {
}

interface IConnectionRepository : IDspRepository!(Connection, ConnectionId) {
}

interface IRemoteTableRepository : IDspRepository!(RemoteTable, RemoteTableId) {
}

interface IDataViewRepository : IDspRepository!(DataView, DataViewId) {
}

interface IDataFlowRepository : IDspRepository!(DataFlow, DataFlowId) {
}

interface ITaskRepository : IDspRepository!(DataTask, TaskId) {
}

interface ITaskChainRepository : IDspRepository!(TaskChain, TaskChainId) {
}

interface ITaskRunRepository : IDspRepository!(TaskRun, TaskRunId) {
  /// Finished runs that ended before the cut-off (std time); returns the count.
  size_t removeFinishedBefore(TenantId t, long cutoff);
}

interface IDataAccessControlRepository : IDspRepository!(DataAccessControl, DataAccessControlId) {
}

interface ICatalogAssetRepository : IDspRepository!(CatalogAsset, CatalogAssetId) {
}

interface IUserAccountRepository : IDspRepository!(UserAccount, UserAccountId) {
}

/// All repositories (passed to the interactors as one bundle).
struct DspRepositories {
  ISpaceRepository spaces;
  ISpaceMemberRepository members;
  IConnectionRepository connections;
  IRemoteTableRepository remoteTables;
  IDataViewRepository views;
  IDataFlowRepository dataFlows;
  ITaskRepository tasks;
  ITaskChainRepository taskChains;
  ITaskRunRepository runs;
  IDataAccessControlRepository accessControls;
  ICatalogAssetRepository catalog;
  IUserAccountRepository users;
}
