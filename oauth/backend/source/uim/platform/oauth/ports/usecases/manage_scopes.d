/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.ports.usecases.manage_scopes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface IManageScopes {
  OAuthScope[] listScopes(TenantId tenantId);
  OAuthScope getScope(TenantId tenantId, OAuthScopeId id);
  OAuthScope createScope(CreateScopeRequest request);
  OAuthScope updateScope(UpdateScopeRequest request);
  /// Fails while a client is still allowed to request the scope.
  void deleteScope(TenantId tenantId, OAuthScopeId id);
}
