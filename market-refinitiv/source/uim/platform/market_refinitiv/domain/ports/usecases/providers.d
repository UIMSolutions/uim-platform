/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.domain.ports.usecases.providers;
import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

interface IManageProvidersUseCase {

  UsecaseResult createProvider(CreateProviderRequest req);
  Provider getProvider(TenantId tenantId, ProviderId id);
  Provider[] listProviders(TenantId tenantId);
  Provider[] listActiveProviders(TenantId tenantId);
  UsecaseResult updateProvider(UpdateProviderRequest req);
  UsecaseResult deleteProvider(TenantId tenantId, ProviderId id);

}
