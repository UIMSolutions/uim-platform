/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.domain.ports.usecases.api_clients;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:

/// Application use case: API client / technical user management.
interface IManageApiClientsUseCase {

  /// Create a new API client.
  ApiClientResponse createClient(CreateApiClientRequest req);

  /// Get client by ID.
  ApiClient getClient(TenantId tenantId, ApiClientId id);

  /// List clients for a tenant.
  ApiClient[] listClients(TenantId tenantId, size_t offset = 0, size_t limit = 100);

  /// Revoke an API client.
  UsecaseResult revokeClient(TenantId tenantId, ApiClientId id);

}
