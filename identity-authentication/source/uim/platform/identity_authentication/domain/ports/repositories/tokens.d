/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.ports.repositories.tokens;
// import uim.platform.identity_authentication.domain.entities.token;
// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Port: outgoing — token persistence.
interface TokenRepository : TenantRepository!(Token, TokenId) {

  bool existsByValue(TenantId tenantId, string tokenValue);
  Token findByValue(TenantId tenantId, string tokenValue);

  Token[] findByUser(TenantId tenantId, UserId userId);
  
  void revoke(TenantId tenantId, TokenId id);
  void revokeAllForUser(TenantId tenantId, UserId userId);
}
