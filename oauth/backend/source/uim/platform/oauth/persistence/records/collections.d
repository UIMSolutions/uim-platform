/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — timestamps as std time) plus
/// the entity fields under their D names. Secrets, tokens and codes are
/// stored as SHA-256 hashes only.
module uim.platform.oauth.persistence.records.collections;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

enum Collections : string {
  clients = "oauth.clients",
  scopes = "oauth.scopes",
  accessTokens = "oauth.accessTokens",
  refreshTokens = "oauth.refreshTokens",
  authorizationCodes = "oauth.authorizationCodes",
  brandings = "oauth.brandings",
  keys = "oauth.keys" /// signing key material (system partition)
}

/// Tenant partition for service wide records (signing key).
enum string systemPartition = "_system";
