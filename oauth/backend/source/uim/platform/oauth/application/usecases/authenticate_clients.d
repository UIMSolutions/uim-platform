/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.authenticate_clients;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class AuthenticateClientsUseCase : IAuthenticateClients {
  protected IOAuthClientRepository clients;

  this(IOAuthClientRepository clients) {
    this.clients = clients;
  }

  OAuthClient authenticate(TenantId tenantId, string clientId, string clientSecret) {
    if (clientId.length == 0)
      protocolError(OAuthError.invalidClient, "Client authentication failed: client_id is missing");
    auto c = clients.findByClientId(tenantId, clientId);
    // the same message for unknown clients and wrong secrets (no client enumeration)
    if (c.isNull || (c.isConfidential && !verifySecret(c.secretSalt, c.secretHash, clientSecret)))
      protocolError(OAuthError.invalidClient, "Client authentication failed");
    if (!c.isActive)
      protocolError(OAuthError.invalidClient, "Client is " ~ cast(string) c.status);
    return c;
  }
}
