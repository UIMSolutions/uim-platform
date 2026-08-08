/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.usecases.oauth_clients;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

interface IManageOAuthClientsUseCase {

  CommandResult createOAuthClient(CreateOAuthClientRequest r);
  CommandResult updateClient(UpdateOAuthClientRequest r);
  CommandResult deleteClient(TenantId tenantId, OAuthClientId id);
  OAuthClient getClient(TenantId tenantId, OAuthClientId id);
  OAuthClient[] listClients(TenantId tenantId);
  OAuthClient[] listClients(TenantId tenantId, string appId);

}
