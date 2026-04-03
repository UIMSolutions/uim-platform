module uim.platform.xyz.domain.entities.personal_data_model;

import domain.types;

/// Defines a field of personal data within a system — what data exists and where.
struct PersonalDataModel
{
    PersonalDataModelId id;
    TenantId tenantId;
    string fieldName;               // e.g. "employee.firstName"
    string fieldDescription;
    PersonalDataCategory category;
    DataSensitivity sensitivity = DataSensitivity.standard;
    string sourceSystem;            // system that holds this field
    string sourceEntity;            // table / object name in source
    DataSubjectType subjectType = DataSubjectType.naturalPerson;
    bool isSpecialCategory;         // GDPR Art. 9
    string legalReference;          // e.g. "GDPR Art. 9(2)(a)"
    long createdAt;
    long updatedAt;
}
