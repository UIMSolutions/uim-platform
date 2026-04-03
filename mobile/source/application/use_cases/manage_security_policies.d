module uim.platform.mobile.application.usecases.manage_security_policies;

import uim.platform.mobile.application.dto;
import uim.platform.mobile.domain.entities.security_policy;
import uim.platform.mobile.domain.ports.security_policy_repository;
import uim.platform.mobile.domain.types;

/// Use case: manage mobile security policies.
class ManageSecurityPoliciesUseCase
{
    private SecurityPolicyRepository repo;

    this(SecurityPolicyRepository repo)
    {
        this.repo = repo;
    }

    CommandResult create(CreateSecurityPolicyRequest req)
    {
        if (req.name.length == 0)
            return CommandResult(false, "", "Policy name is required");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        SecurityPolicy p;
        p.id = id;
        p.tenantId = req.tenantId;
        p.name = req.name;
        p.description = req.description;
        p.enforcementLevel = parseEnforcement(req.enforcementLevel);
        p.allowedAuthTypes = parseAuthTypes(req.allowedAuthTypes);
        p.sessionTimeoutMinutes = req.sessionTimeoutMinutes > 0 ? req.sessionTimeoutMinutes : 30;
        p.maxFailedLogins = req.maxFailedLogins > 0 ? req.maxFailedLogins : 5;
        p.requireBiometric = req.requireBiometric;
        p.allowOfflineAccess = req.allowOfflineAccess;
        p.offlineAccessDurationHours = req.offlineAccessDurationHours > 0 ? req.offlineAccessDurationHours : 168;
        p.encryptLocalStorage = req.encryptLocalStorage;
        p.preventScreenCapture = req.preventScreenCapture;
        p.preventCopyPaste = req.preventCopyPaste;
        p.enableDataLossPrevention = req.enableDataLossPrevention;
        p.requireSsl = req.requireSsl;
        p.enableCertificatePinning = req.enableCertificatePinning;
        p.pinnedCertificates = req.pinnedCertificates;
        p.blockJailbroken = req.blockJailbroken;
        p.blockRooted = req.blockRooted;
        p.enableAppIntegrityCheck = req.enableAppIntegrityCheck;
        p.minimumOsVersion = req.minimumOsVersion;
        p.allowedIpRanges = req.allowedIpRanges;
        p.blockedCountries = req.blockedCountries;
        p.enableAuditLogging = req.enableAuditLogging;
        p.logRetentionDays = req.logRetentionDays > 0 ? req.logRetentionDays : 90;
        p.createdBy = req.createdBy;
        p.createdAt = clockSeconds();
        p.updatedAt = p.createdAt;

        repo.save(p);
        return CommandResult(true, id, "");
    }

    SecurityPolicy getById(SecurityPolicyId id) { return repo.findById(id); }
    SecurityPolicy[] listByTenant(TenantId tenantId) { return repo.findByTenant(tenantId); }

    CommandResult remove(SecurityPolicyId id)
    {
        auto p = repo.findById(id);
        if (p.id.length == 0)
            return CommandResult(false, "", "Security policy not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}

private EnforcementLevel parseEnforcement(string s)
{
    switch (s)
    {
    case "optional": return EnforcementLevel.optional;
    case "required": return EnforcementLevel.required;
    case "strict": return EnforcementLevel.strict;
    default: return EnforcementLevel.recommended;
    }
}

private MobileAuthType[] parseAuthTypes(string[] types)
{
    MobileAuthType[] result;
    foreach (t; types)
    {
        switch (t)
        {
        case "oauth2": result ~= MobileAuthType.oauth2; break;
        case "saml": result ~= MobileAuthType.saml; break;
        case "basicAuth": result ~= MobileAuthType.basicAuth; break;
        case "certificateBased": result ~= MobileAuthType.certificateBased; break;
        case "biometric": result ~= MobileAuthType.biometric; break;
        case "apiKey": result ~= MobileAuthType.apiKey; break;
        default: break;
        }
    }
    return result;
}

private long clockSeconds()
{
    import core.time : MonoTime;
    return MonoTime.currTime.ticks / 1_000_000_000;
}
