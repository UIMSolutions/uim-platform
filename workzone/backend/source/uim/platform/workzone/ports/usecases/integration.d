/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.ports.usecases.integration;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// UI integration cards. Cards used by widgets cannot be deleted.
interface IManageCardsUseCase : IManageResource!(Card, CardId, CreateCardRequest, UpdateCardRequest) {
  UsecaseResult activate(TenantId tenantId, CardId id, UserId actor);
  UsecaseResult deactivate(TenantId tenantId, CardId id, UserId actor);
}

/// Registered business apps. Apps used by widgets or navigation cannot be deleted.
interface IManageAppsUseCase : IManageResource!(AppRegistration, AppId, CreateAppRequest, UpdateAppRequest) {
  UsecaseResult activate(TenantId tenantId, AppId id, UserId actor);
  UsecaseResult deactivate(TenantId tenantId, AppId id, UserId actor);
  UsecaseResult deprecate(TenantId tenantId, AppId id, UserId actor);
}

/// External content providers (connection and synchronisation via the gateway).
interface IManageContentProvidersUseCase : IManageResource!(ExternalContentProvider, ExternalContentProviderId,
    CreateProviderRequest, UpdateProviderRequest) {
  UsecaseResult connect(TenantId tenantId, ExternalContentProviderId id, UserId actor);
  UsecaseResult disconnect(TenantId tenantId, ExternalContentProviderId id, UserId actor);
  UsecaseResult sync(TenantId tenantId, ExternalContentProviderId id, UserId actor);
}

/// Shell plugins.
interface IManageShellPluginsUseCase : IManageResource!(ShellPlugin, ShellPluginId, CreatePluginRequest, UpdatePluginRequest) {
  UsecaseResult activate(TenantId tenantId, ShellPluginId id, UserId actor);
  UsecaseResult deactivate(TenantId tenantId, ShellPluginId id, UserId actor);
}
