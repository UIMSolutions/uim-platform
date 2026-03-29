module uim.platform.identity_authentication.application.use_cases.authenticate_user;

import uim.platform.identity_authentication.domain.entities.user;
import uim.platform.identity_authentication.domain.entities.session;
import uim.platform.identity_authentication.domain.entities.risk_rule;
import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication.domain.ports.user;
import uim.platform.identity_authentication.domain.ports.password_service;
import uim.platform.identity_authentication.domain.ports.session;
import uim.platform.identity_authentication.domain.ports.risk_rule;
import uim.platform.identity_authentication.domain.ports.mfa_service;
import uim.platform.identity_authentication.domain.services.risk_evaluator;
import uim.platform.identity_authentication.application.dto;

import std.uuid;
import core.time;
import std.datetime.systime : Clock;

/// Application use case: authenticate a user with form-based credentials.
class AuthenticateUserUseCase
{
    private UserRepository userRepo;
    private PasswordService passwordSvc;
    private SessionRepository sessionRepo;
    private RiskRuleRepository riskRuleRepo;
    private MfaService mfaSvc;

    this(UserRepository userRepo, PasswordService passwordSvc,
        SessionRepository sessionRepo, RiskRuleRepository riskRuleRepo,
        MfaService mfaSvc)
    {
        this.userRepo = userRepo;
        this.passwordSvc = passwordSvc;
        this.sessionRepo = sessionRepo;
        this.riskRuleRepo = riskRuleRepo;
        this.mfaSvc = mfaSvc;
    }

    AuthResult execute(AuthRequest req)
    {
        // Find user
        auto user = userRepo.findByEmail(req.tenantId, req.email);
        if (user == User.init)
            return AuthResult(false, "Invalid credentials");

        if (!user.isActive())
            return AuthResult(false, "User account is not active");

        // Verify password
        if (!passwordSvc.verifyPassword(req.password, user.passwordHash))
            return AuthResult(false, "Invalid credentials");

        // Risk evaluation
        auto riskRules = riskRuleRepo.findByTenant(req.tenantId);
        auto riskCtx = RiskEvaluationContext(
            req.ipAddress, req.userAgent, AuthMethod.form,
            user.groupIds, "employee"
        );
        auto riskLevel = evaluateRisk(riskRules, user, riskCtx);
        auto requiredMfa = requiredMfaForRisk(riskRules, user, riskCtx);

        // Check if MFA is required but not provided
        if (requiredMfa != MfaType.none || user.hasMfa())
        {
            auto effectiveMfa = requiredMfa != MfaType.none ? requiredMfa : user.mfaType;
            if (req.mfaCode.length == 0)
                return AuthResult(false, "MFA code required", true, effectiveMfa);

            if (!mfaSvc.validateCode(effectiveMfa, user.mfaSecret, req.mfaCode))
                return AuthResult(false, "Invalid MFA code");
        }

        // Create session
        auto now = Clock.currStdTime();
        auto session = Session(
            randomUUID().toString(),
            user.id,
            req.tenantId,
            req.applicationId,
            AuthMethod.form,
            requiredMfa,
            req.ipAddress,
            req.userAgent,
            riskLevel,
            now,
            now + dur!"hours"(8).total!"hnsecs",
            false
        );
        sessionRepo.save(session);

        return AuthResult(true, "Authentication successful", false, MfaType.none, session.id, user.id);
    }
}
