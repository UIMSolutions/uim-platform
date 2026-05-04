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

  Json toJson() const {
    return Json([
      "name": name,
      "dataType": dataType,
      "semanticType": semanticType,
      "description": description,
      "isKey": isKey,
      "isMeasure": isMeasure
    ]);
  }
}

struct ViewAssociation {
  string targetViewId;
  string joinType;
  string[] onColumns;

  Json toJson() const {
    return Json([
      "targetViewId": targetViewId,
      "joinType": joinType,
      "onColumns": onColumns
    ]);
  }
}

struct View {
  mixin TenantEntity!ViewId;

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
  
  Json toJson() const {
    return entityToJson
      .set("spaceId", spaceId)
      .set("name", name)
      .set("description", description)
      .set("businessName", businessName)
      .set("semantic", semantic.to!string)
      .set("columns", columns.map!(c => c.toJson()).array)
      .set("associations", associations.map!(a => a.toJson()).array)
      .set("sqlExpression", sqlExpression)
      .set("isExposed", isExposed)
      .set("isPersisted", isPersisted)
      .set("rowCount", rowCount);
  }

}
