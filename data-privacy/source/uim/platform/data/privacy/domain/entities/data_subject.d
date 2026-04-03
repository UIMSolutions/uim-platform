/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.data_subject;

import uim.platform.data.privacy.domain.types;

/// A data subject — an identified or identifiable natural person (GDPR Art. 4(1)).
struct DataSubject
{
  DataSubjectId id;
  TenantId tenantId;
  DataSubjectType subjectType = DataSubjectType.naturalPerson;
  string externalId; // ID in the source system
  string displayName;
  string email;
  string sourceSystem; // e.g. "SAP HCM", "SAP CRM", "S/4HANA"
  string country; // ISO 3166-1 alpha-2
  bool isActive = true;
  long createdAt;
  long updatedAt;
}
