/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.usecases.providers;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Content providers.
interface IManageProvidersUseCase : IManageResource!(ContentProvider, ContentProviderId,
    CreateProviderRequest, UpdateProviderRequest) {
  /// Probe the provider endpoint and record the result.
  UsecaseResult sync(TenantId tenantId, ContentProviderId id, UserId actor);
  UsecaseResult activate(TenantId tenantId, ContentProviderId id, UserId actor);
  UsecaseResult deactivate(TenantId tenantId, ContentProviderId id, UserId actor);
}
