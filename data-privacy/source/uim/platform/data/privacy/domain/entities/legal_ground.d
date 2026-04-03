module uim.platform.data.privacy.domain.entities.legal_ground;

import uim.platform.data.privacy.domain.types;

/// A recorded legal basis for processing personal data (GDPR Art. 6 / Art. 9).
struct LegalGround
{
    LegalGroundId id;
    TenantId tenantId;
    DataSubjectId dataSubjectId;
    LegalBasis basis;
    ProcessingPurpose purpose;
    string description;             // human-readable explanation
    string legalReference;          // e.g. "GDPR Art. 6(1)(b)"
    PersonalDataCategory[] categories;  // what data categories this covers
    bool isActive = true;
    long validFrom;
    long validUntil;                // 0 = indefinite
    long createdAt;
}
