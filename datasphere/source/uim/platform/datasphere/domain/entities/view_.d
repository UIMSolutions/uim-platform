/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.view_;

// import uim.platform.datasphere.domain.types;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
struct ViewColumn {
  string name;
  string dataType;
  string semanticType;
  string description;
  bool isKey;
  bool isMeasure;
}

struct ViewAssociation {
  string targetViewId;
  string joinType;
  string[] onColumns;
}

struct View {
  ViewId id;
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  string businessName;
  ViewSemantic semantic;
  ViewColumn[] columns;
  ViewAssociation[] associations;
  string sqlExpression;
  bool isExposed;
  bool isPersisted;
  long rowCount;
  long createdAt;
  long updatedAt;
}
