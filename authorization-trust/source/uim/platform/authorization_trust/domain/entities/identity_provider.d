/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.entities.identity_provider;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:
/// A trusted identity provider (SAML 2.0 or OIDC).
/// Mirrors the SAP BTP trust configuration for external IdPs.
struct IdentityProvider {
  mixin TenantEntity!IdentityProviderId;
  string             alias_;       // unique short alias, e.g. "corporate-idp"
  string             displayName;
  IdpType            idpType;      // saml2 | oidc
  string             metadataUrl;  // URL to SAML metadata or OIDC discovery doc
  string             entityId;     // SAML EntityID / OIDC issuer
  string             ssoUrl;       // SAML SSO endpoint
  string             sloUrl;       // SAML SLO endpoint
  string             signingCert;  // PEM-encoded signing certificate
  bool               isActive;
  bool               isDefault;    // whether this is the default IdP for the tenant

  Json toJson() const {
    return entityToJson
      .set("alias", alias_)
      .set("displayName", displayName)
      .set("idpType", idpType.to!string)
      .set("metadataUrl", metadataUrl)
      .set("entityId", entityId)
      .set("ssoUrl", ssoUrl)
      .set("sloUrl", sloUrl)
      .set("signingCert", signingCert)
      .set("isActive", isActive)
      .set("isDefault", isDefault);
  }
}
