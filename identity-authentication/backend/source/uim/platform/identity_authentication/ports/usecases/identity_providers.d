/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.usecases.identity_providers;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driving port: delegated authentication to corporate identity providers.
interface IManageIdentityProvidersUseCase {
  IdpConfig[] listIdps(TenantId tenantId);
  IdpConfig getIdp(TenantId tenantId, IdpConfigId id);

  UsecaseResult createIdp(IdpConfigDTO dto);
  UsecaseResult updateIdp(IdpConfigDTO dto);
  UsecaseResult deleteIdp(TenantId tenantId, IdpConfigId id);

  /// The IdP for an e-mail address: domain hint match, else the default IdP.
  IdpConfig resolveIdp(TenantId tenantId, string email);
  /// Authorization request URL (URL-encoded) for an OIDC IdP; "" for others.
  string buildAuthorizationUrl(const IdpConfig idp, string redirectUri, string state);
}
