/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.persistence.mappers.app_definition;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// AppDefinition ⇄ snapshot record.
struct AppDefinitionMapper {
  static Json toRecord(const AppDefinition e) {
    auto r = baseRecord(e);
    r["applicationId"] = e.applicationId.value;
    r["name"] = e.name;
    r["description"] = e.description;
    r["status"] = enumValue(e.status);
    r["definitionContent"] = e.definitionContent;
    r["definitionFormat"] = e.definitionFormat;
    r["schemaVersion"] = e.schemaVersion;
    r["authoredBy"] = e.authoredBy.value;
    r["targetPlatform"] = e.targetPlatform;
    r["businessObjectModel"] = e.businessObjectModel;
    r["validationPassed"] = e.validationPassed;
    r["validationErrors"] = e.validationErrors;
    r["publishedAt"] = e.publishedAt;
    return r;
  }

  static AppDefinition fromRecord(Json r) {
    AppDefinition e;
    readBase(e, r);
    e.applicationId = MobileApplicationId(fieldString(r, "applicationId"));
    e.name = fieldString(r, "name");
    e.description = fieldString(r, "description");
    e.status = fieldEnum!DefinitionStatus(r, "status", DefinitionStatus.draft);
    e.definitionContent = fieldString(r, "definitionContent");
    e.definitionFormat = fieldString(r, "definitionFormat");
    e.schemaVersion = fieldString(r, "schemaVersion");
    e.authoredBy = UserId(fieldString(r, "authoredBy"));
    e.targetPlatform = fieldString(r, "targetPlatform");
    e.businessObjectModel = fieldString(r, "businessObjectModel");
    e.validationPassed = fieldBool(r, "validationPassed");
    e.validationErrors = fieldString(r, "validationErrors");
    e.publishedAt = fieldLong(r, "publishedAt");
    return e;
  }
}
