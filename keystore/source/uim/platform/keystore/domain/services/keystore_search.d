/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.services.keystore_search;

import uim.platform.keystore.domain.entities.keystore_entity;
import uim.platform.keystore.domain.ports.repositories.keystore_repository;
import uim.platform.keystore.domain.types;

@safe:

/// Implements the SAP BTP keystore search-order logic:
/// subscription level -> application level -> account level.
class KeystoreSearchService {
  private KeystoreRepository repo;

  this(KeystoreRepository repo) {
    this.repo = repo;
  }

  /// Find a keystore by name, respecting the three-level search order.
  /// Returns KeystoreEntity.init when not found at any level.
  KeystoreEntity findByName(string accountId, string applicationId, string subscriptionId, string name) {
    // 1. Subscription level (most specific)
    if (subscriptionId.length > 0) {
      auto ks = repo.findByName(accountId, subscriptionId, KeystoreLevel.subscription, name);
      if (ks.id.length > 0)
        return ks;
    }

    // 2. Application level
    if (applicationId.length > 0) {
      auto ks = repo.findByName(accountId, applicationId, KeystoreLevel.application, name);
      if (ks.id.length > 0)
        return ks;
    }

    // 3. Account level (least specific, shared across all applications)
    return repo.findByName(accountId, "", KeystoreLevel.account, name);
  }
}
