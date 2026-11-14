/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.ports.usecases.manage_clients;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface IManageClients {
  OAuthClient[] listClients(TenantId tenantId);
  OAuthClient getClient(TenantId tenantId, OAuthClientId id);
  /// The plain secret is part of the result only here and in rotateSecret.
  ClientCredentials createClient(CreateClientRequest request);
  /// Blocking a client revokes all of its tokens.
  OAuthClient updateClient(UpdateClientRequest request);
  /// Also removes the tokens and codes of the client.
  void deleteClient(TenantId tenantId, OAuthClientId id);
  /// New secret; tokens issued with the old one are revoked.
  ClientCredentials rotateSecret(TenantId tenantId, OAuthClientId id, UserId actor);
}
