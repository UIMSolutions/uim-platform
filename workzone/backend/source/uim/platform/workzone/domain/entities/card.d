/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.card;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A UI integration card (sap.card manifest) usable in widgets.
struct Card {
  mixin TenantEntity!CardId;

  string title; /// unique per tenant
  string subtitle;
  string description;
  string icon;
  CardType cardType = CardType.list;
  bool active = true;

  // data source
  string dataSourceUrl;
  string dataSourceMethod = "GET";
  string dataSourcePath;
  int refreshIntervalSec;
  string authType = "none"; /// none | bearer | basic | oauth2
  string authToken; /// secret

  // manifest
  string manifestType = "sap.card";
  string manifestVersion = "1.0.0";
  string headerTitle;
  string headerSubtitle;
  string headerIcon;
  string headerStatus;
  int maxItems = 5;

  string[] allowedRoles;
}
