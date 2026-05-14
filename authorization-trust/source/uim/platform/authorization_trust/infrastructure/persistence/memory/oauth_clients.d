/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.persistence.memory.oauth_clients;

import uim.platform.authorization_trust;
import uim.platform.mobile;

mixin(Showmodule!());

@safe:

mixin(ShowModule!());

@safe:

class MemoryOAuthClientRepository : OAuthClientRepository {
  private OAuthClientEntity[OAuthClientId] store;

  bool existsById(OAuthClientId id) {
    return (id in store) !is null;
  }

  OAuthClientEntity findById(OAuthClientId id) {
    return existsById(id) ? store[id] : OAuthClientEntity.init;
  }

  bool existsByClientId(string clientId) {
    return findByClientId(clientId).id.length > 0;
  }

  OAuthClientEntity findByClientId(string clientId) {
    foreach (c; store.values)
      if (c.clientId == clientId)
        return c;
    return OAuthClientEntity.init;
  }

  OAuthClientEntity[] findAll() {
    return store.values.dup;
  }

  OAuthClientEntity[] findByAppId(string appId) {
    return store.values.filter!(c => c.appId == appId).array;
  }

  void save(OAuthClientEntity client) {
    store[client.id] = client;
  }

  void update(OAuthClientEntity client) {
    store[client.id] = client;
  }

  void remove(OAuthClientId id) {
    store.remove(id);
  }

  size_t count() {
    return store.length;
  }
}
