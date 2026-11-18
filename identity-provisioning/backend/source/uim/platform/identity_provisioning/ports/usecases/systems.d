/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.ports.usecases.systems;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Maintain the connector configuration of source, target or proxy systems.
interface IManageSystemsUseCase(TEntity, TId) : IManageResource!(TEntity, TId,
    CreateRootRequest!SystemSpec, UpdateRequest!(TId, SystemSpec)) {
  /// Test the connection; on success the system becomes active, otherwise error.
  UsecaseResult activate(TenantId tenantId, TId id, UserId actor);
  /// active / error → inactive (jobs refuse inactive systems).
  UsecaseResult deactivate(TenantId tenantId, TId id, UserId actor);
  /// Test the connection without changing an active/inactive status.
  UsecaseResult testConnection(TenantId tenantId, TId id, UserId actor);
  TEntity findByName(TenantId tenantId, string name);
}

alias IManageSourceSystemsUseCase = IManageSystemsUseCase!(SourceSystem, SourceSystemId);
alias IManageTargetSystemsUseCase = IManageSystemsUseCase!(TargetSystem, TargetSystemId);
alias IManageProxySystemsUseCase = IManageSystemsUseCase!(ProxySystem, ProxySystemId);
