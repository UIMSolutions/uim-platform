/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.domain.ports.usecases.providers;
import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

/// Port: outgoing — provider management use case.
interface IManageProvidersUseCase {

  /// Creates a new provider in the system.
  /// @param req The request containing the provider details.
  UsecaseResult createProvider(CreateProviderRequest req);

  /// Retrieves a provider by its ID for a given tenant.
  /// @param tenantId The tenant ID.
  /// @param id The ID of the provider to retrieve.
  Provider getProvider(TenantId tenantId, ProviderId id);

  /// Lists all providers for a given tenant.
  /// @param tenantId The tenant ID.
  Provider[] listProviders(TenantId tenantId);

  /// Lists all active providers for a given tenant.
  /// @param tenantId The tenant ID.
  Provider[] listActiveProviders(TenantId tenantId);

  /// Updates an existing provider in the system.
  /// @param req The request containing the updated provider details.
  UsecaseResult updateProvider(UpdateProviderRequest req);

  /// Deletes a provider from the system.
  /// @param tenantId The tenant ID.
  /// @param id The ID of the provider to delete.
  UsecaseResult deleteProvider(TenantId tenantId, ProviderId id);

}
