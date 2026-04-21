/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.personal_data_model;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Defines a field of personal data within a system — what data exists and where.
struct PersonalDataModel {
  mixin TenantEntity!(PersonalDataModelId);

  string fieldName; // e.g. "employee.firstName"
  string fieldDescription;
  PersonalDataCategory category;
  DataSensitivity sensitivity = DataSensitivity.standard;
  string sourceSystem; // system that holds this field
  string sourceEntity; // table / object name in source
  DataSubjectType subjectType = DataSubjectType.naturalPerson;
  bool isSpecialCategory; // GDPR Art. 9
  string legalReference; // e.g. "GDPR Art. 9(2)(a)"

  Json toJson() const {
    return Json.entityToJson
      .set("fieldName", fieldName)
      .set("fieldDescription", fieldDescription)
      .set("category", category.to!string)
      .set("sensitivity", sensitivity.to!string)
      .set("sourceSystem", sourceSystem)
      .set("sourceEntity", sourceEntity)
      .set("subjectType", subjectType.to!string)
      .set("isSpecialCategory", isSpecialCategory)
      .set("legalReference", legalReference);
  }
}
