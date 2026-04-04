/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.card;

import uim.platform.workzone.domain.types;

/// Integration card — a modular content unit displaying data from business systems.
struct Card {
  CardId id;
  TenantId tenantId;
  string title;
  string subtitle;
  string description;
  string icon;
  CardType cardType = CardType.list;
  CardDataSource dataSource;
  CardManifest manifest;
  RoleId[] allowedRoleIds;
  bool active = true;
  long createdAt;
  long updatedAt;
}

/// Data source configuration for a card.
struct CardDataSource {
  string url; // OData or REST endpoint
  string method; // GET, POST
  string path; // request path
  int refreshIntervalSec; // auto-refresh interval
  string authType; // "none", "bearer", "basic", "oauth2"
  string authToken; // token or reference
}

/// Card manifest (simplified descriptor).
struct CardManifest {
  string type; // "sap.card"
  string version_;
  string minVersion;
  string headerTitle;
  string headerSubtitle;
  string headerIcon;
  string headerStatus;
  int maxItems;
}
