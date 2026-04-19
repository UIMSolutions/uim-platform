/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.entities.favorite;

import uim.platform.dms.application.domain.types;

struct Favorite {
  FavoriteId id;
  TenantId tenantId;
  UserId userId;
  string resourceId; // documentId or folderId
  ResourceType resourceType;
  long createdAt;
}
