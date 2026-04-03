module uim.platform.data.privacy.domain.services.legal_basis_evaluator;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.legal_ground;
import uim.platform.data.privacy.domain.entities.consent_record;
import uim.platform.data.privacy.domain.ports.legal_ground_repository;
import uim.platform.data.privacy.domain.ports.consent_record_repository;

/// Result of a legal basis evaluation.
struct LegalBasisEvaluation
{
    bool hasValidBasis;
    string[] activeBases;       // descriptions of valid legal grounds
    string[] issues;            // reasons if no valid basis found
}

/// Domain service — evaluates whether processing has a valid legal basis.
class LegalBasisEvaluator
{
    private LegalGroundRepository groundRepo;
    private ConsentRecordRepository consentRepo;

    this(LegalGroundRepository groundRepo, ConsentRecordRepository consentRepo)
    {
        this.groundRepo = groundRepo;
        this.consentRepo = consentRepo;
    }

    /// Check if a data subject has a valid legal basis for a given purpose.
    LegalBasisEvaluation evaluate(TenantId tenantId, DataSubjectId subjectId,
        ProcessingPurpose purpose)
    {
        import std.datetime.systime : Clock;
        import std.conv : to;

        LegalBasisEvaluation result;
        auto now = Clock.currStdTime();

        // Check legal grounds
        auto grounds = groundRepo.findActive(tenantId, subjectId);
        foreach (ref g; grounds)
        {
            if (g.purpose == purpose && g.isActive)
            {
                // Check validity period
                if (g.validUntil > 0 && g.validUntil < now)
                    continue;
                if (g.validFrom > now)
                    continue;
                result.activeBases ~= g.basis.to!string ~ ": " ~ g.description;
            }
        }

        // Check active consents for consent-based processing
        auto consents = consentRepo.findActiveConsents(tenantId, subjectId);
        foreach (ref c; consents)
        {
            if (c.purpose == purpose && c.status == ConsentStatus.granted)
            {
                if (c.expiresAt > 0 && c.expiresAt < now)
                    continue;
                result.activeBases ~= "consent: " ~ c.consentText;
            }
        }

        result.hasValidBasis = result.activeBases.length > 0;

        if (!result.hasValidBasis)
        {
            result.issues ~= "No valid legal ground found for purpose "
                ~ purpose.to!string;
            result.issues ~= "No active consent found for this purpose";
        }

        return result;
    }
}
