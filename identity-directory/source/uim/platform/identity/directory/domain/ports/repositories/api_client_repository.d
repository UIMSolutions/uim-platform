/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.ports.repositories.api_clients;

import uim.platform.identity.directory.domain.entities.api_client;
import uim.platform.identity.directory.domain.types;

/// Port: outgoing — API client persistence.
interface ApiClientRepository : ITenantRepository!(ApiClient, ApiClientId) {

  size_t countByClientId(string clientId);
  ApiClient findByClientId(string clientId);
  void removeByClientId(string clientId);

}
