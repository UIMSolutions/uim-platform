/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.ports.usecases.content_providers;

import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// Application service for content provider registration and management.
interface IManageContentProvidersUseCase { 

  UsecaseResult registerProvider(RegisterProviderRequest req);
  UsecaseResult updateProvider(UpdateProviderRequest req);
  UsecaseResult deregisterProvider(TenantId tenantId, ContentProviderId id);
  UsecaseResult syncProvider(TenantId tenantId, ContentProviderId id);
  ContentProvider getProvider(TenantId tenantId, ContentProviderId id);
  ContentProvider[] listProviders(TenantId tenantId);
  ContentProvider[] listActiveProviders(TenantId tenantId);

}
