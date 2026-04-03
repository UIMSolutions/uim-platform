module uim.platform.xyz.domain.entities.data_subject;

import uim.platform.xyz.domain.types;

/// A data subject — an identified or identifiable natural person (GDPR Art. 4(1)).
struct DataSubject {
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
