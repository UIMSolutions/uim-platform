/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.card;

import uim.platform.workzone.domain.types;

/// Integration card — a modular content unit displaying data from business systems.
struct Card {
  mixin TenantEntity!(CardId);
  string title;
  string subtitle;
  string description;
  string icon;
  CardType cardType = CardType.list;
  CardDataSource dataSource;
  CardManifest manifest;
  RoleId[] allowedRoleIds;
  bool active = true;
  
  Json toJson() const {
    auto j = entityToJson
      .set("title", title)
      .set("subtitle", subtitle)
      .set("description", description)
      .set("icon", icon)
      .set("cardType", cardType.toString())
      .set("dataSource", Json.init
        .set("url", dataSource.url)
        .set("method", dataSource.method)
        .set("path", dataSource.path)
        .set("refreshIntervalSec", dataSource.refreshIntervalSec)
        .set("authType", dataSource.authType)
        .set("authToken", dataSource.authToken))
      .set("manifest", Json.init
        .set("type", manifest.type)
        .set("version", manifest.version_)
        .set("minVersion", manifest.minVersion)
        .set("headerTitle", manifest.headerTitle)
        .set("headerSubtitle", manifest.headerSubtitle)
        .set("headerIcon", manifest.headerIcon)
        .set("headerStatus", manifest.headerStatus)
        .set("maxItems", manifest.maxItems))
      .set("allowedRoleIds", allowedRoleIds.map!(r => r.value).array)
      .set("active", active);

    return j;
  }
}

/// Data source configuration for a card.
struct CardDataSource {
  string url; // OData or REST endpoint
  string method; // GET, POST
  string path; // request path
  int refreshIntervalSec; // auto-refresh interval
  string authType; // "none", "bearer", "basic", "oauth2"
  string authToken; // token or reference

  Json toJson() const {
    return Json.emptyObject
      .set("url", url)
      .set("method", method)
      .set("path", path)
      .set("refreshIntervalSec", refreshIntervalSec)
      .set("authType", authType)
      .set("authToken", authToken);
  }
}

/// Card manifest (simplified descriptor).
struct CardManifest {
  string type; // "sap.card", "custom.card", etc.
  string version_;
  string minVersion;
  string headerTitle;
  string headerSubtitle;
  string headerIcon;
  string headerStatus;
  int maxItems;

  Json toJson() const {
    return Json.emptyObject
      .set("type", type)
      .set("version", version_)
      .set("minVersion", minVersion)
      .set("headerTitle", headerTitle)
      .set("headerSubtitle", headerSubtitle)
      .set("headerIcon", headerIcon)
      .set("headerStatus", headerStatus)
      .set("maxItems", maxItems);
  }
}