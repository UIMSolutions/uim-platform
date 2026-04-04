/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.personal_data_model;

import uim.platform.data.privacy.domain.types;

/// Defines a field of personal data within a system — what data exists and where.
struct PersonalDataModel {
  PersonalDataModelId id;
  TenantId tenantId;
  string fieldName; // e.g. "employee.firstName"
  string fieldDescription;
  PersonalDataCategory category;
  DataSensitivity sensitivity = DataSensitivity.standard;
  string sourceSystem; // system that holds this field
  string sourceEntity; // table / object name in source
  DataSubjectType subjectType = DataSubjectType.naturalPerson;
  bool isSpecialCategory; // GDPR Art. 9
  string legalReference; // e.g. "GDPR Art. 9(2)(a)"
  long createdAt;
  long updatedAt;
}
