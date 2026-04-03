/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.entities.namespace;

import uim.platform.credential_store.domain.types;

struct Namespace {
  NamespaceId id;
  TenantId tenantId;
  string name;
  string description;
  long createdAt;
  long updatedAt;
  string createdBy;
}
