/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.entities.oauth_client;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

/// A registered OAuth 2.0 client application.
/// Corresponds to an SAP BTP XSUAA service instance binding.
struct OAuthClientEntity {
  OAuthClientId id;
  string        clientId;          // OAuth 2.0 client_id (unique per application)
  string        clientSecret;      // hashed secret (confidential clients only)
  string        name;              // display name
  string        description;
  GrantType[]   grantTypes;        // allowed grant types
  string[]      scopes;            // OAuth scopes this client may request
  string[]      redirectUris;      // allowed redirect URIs (authorization_code flow)
  ClientType    clientType;        // confidential | public
  string        appId;             // owning application / tenant
  long          createdAt;
  long          updatedAt;
}
