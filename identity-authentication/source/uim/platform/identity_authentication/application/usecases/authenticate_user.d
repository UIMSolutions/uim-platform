/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.authenticate_user;
// import uim.platform.identity_authentication.domain.entities.user;
// import uim.platform.identity_authentication.domain.entities.session;
// import uim.platform.identity_authentication.domain.entities.risk_rule;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.user;
// import uim.platform.identity_authentication.domain.ports.repositories.password_service;
// import uim.platform.identity_authentication.domain.ports.repositories.session;
// import uim.platform.identity_authentication.domain.ports.repositories.risk_rule;
// import uim.platform.identity_authentication.domain.ports.repositories.mfa_service;
// import uim.platform.identity_authentication.domain.services.risk_evaluator;
// import uim.platform.identity_authentication.application.dto;
// 
// 
// import core.time;
// 
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Application use case: authenticate a user with form-based credentials.
class AuthenticateUserUseCase { // TODO: UIMUseCase {
  private UserRepository userRepo;
  private PasswordService passwordSvc;
  private SessionRepository sessionRepo;
  private RiskRuleRepository riskRuleRepo;
  private MfaService mfaSvc;

  this(UserRepository userRepo, PasswordService passwordSvc,
      SessionRepository sessionRepo, RiskRuleRepository riskRuleRepo, MfaService mfaSvc) {
    this.userRepo = userRepo;
    this.passwordSvc = passwordSvc;
    this.sessionRepo = sessionRepo;
    this.riskRuleRepo = riskRuleRepo;
    this.mfaSvc = mfaSvc;
  }

  AuthResult execute(AuthRequest req) {
    // Find user
    auto user = userRepo.findByEmail(req.tenantId, req.email);
    if (user.isNull)
      return AuthResult(false, "Invalid credentials");

    if (!user.isActive())
      return AuthResult(false, "IAUser account is not active");

    // Verify password
    if (!passwordSvc.verifyPassword(req.password, user.passwordHash))
      return AuthResult(false, "Invalid credentials");

    // Risk evaluation
    auto riskRules = riskRuleRepo.findByTenant(req.tenantId);
    auto riskCtx = RiskEvaluationContext(req.ipAddress, req.userAgent,
        AuthMethod.form, user.groupIds, "employee");
    auto riskLevel = evaluateRisk(riskRules, user, riskCtx);
    auto requiredMfa = requiredMfaForRisk(riskRules, user, riskCtx);

    // Check if MFA is required but not provided
    if (requiredMfa != MfaType.none || user.hasMfa()) {
      auto effectiveMfa = requiredMfa != MfaType.none ? requiredMfa : user.mfaType;
      if (req.mfaCode.length == 0)
        return AuthResult(false, "MFA code required", true, effectiveMfa);

      if (!mfaSvc.validateCode(effectiveMfa, user.mfaSecret, req.mfaCode))
        return AuthResult(false, "Invalid MFA code");
    }

    // Create session
    auto now = currentTimestamp();
    auto session = IASession(req.tenantId, SessionId(randomUUID().toString()), user.id);
    session.applicationId = req.applicationId;
    session.authMethod = AuthMethod.form;
    // TODO: session.requiredMfa = requiredMfa;
    session.ipAddress = req.ipAddress;
    session.userAgent = req.userAgent;
    session.riskLevel = riskLevel;
    session.expiresAt = session.createdAt + dur!"hours"(8).total!"hnsecs";
    session.revoked = false;
    sessionRepo.save(session);

    return AuthResult(true, "Authentication successful", false, MfaType.none, session.id.value, user.id);
  }
}
