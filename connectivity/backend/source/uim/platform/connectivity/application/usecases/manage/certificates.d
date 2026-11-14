/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.manage.certificates;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Interactor: certificate store. Status follows the validity period; revoked
/// certificates are frozen; certificates used by destinations cannot be deleted.
class ManageCertificatesUseCase
  : ResourceUseCase!(Certificate, CertificateId, CreateCertificateRequest, UpdateCertificateRequest),
  IManageCertificatesUseCase {

  protected MonitoringPolicy policy;

  this(ConnectivityRepositories repos, EventRecorder events, MonitoringPolicy policy) {
    super(repos, repos.certificates, events, "Certificate", "connectivity.certificate");
    this.policy = policy;
  }

  override protected Certificate build(CreateCertificateRequest r) {
    auto c = Certificate(r.tenantId);
    assignMatching(c, r.spec);
    c.name = c.name.strip;
    check(c);
    ensureUnique(repos.certificates.findByName(r.tenantId, c.name), c, "this tenant");
    return c;
  }

  override protected void apply(ref Certificate c, CertificateSpec spec) {
    ensureState(c.status != CertificateStatus.revoked, "Certificate '" ~ c.name ~ "' is revoked and cannot be changed");
    assignMatching(c, spec);
    c.name = c.name.strip;
    check(c);
    ensureUnique(repos.certificates.findByName(c.tenantId, c.name), c, "this tenant");
  }

  protected void check(ref Certificate c) {
    validateDisplayName("Certificate", c.name);
    c.fingerprint = normalizeFingerprint(c.fingerprint);
    validateValidity(c);
    refreshStatus(c);
  }

  protected void refreshStatus(ref Certificate c) {
    auto now = nowStdTime();
    c.status = validityAt(c, now, policy.certificateWarningDays);
    final switch (c.status) {
    case CertificateStatus.valid:
      c.statusMessage = "";
      break;
    case CertificateStatus.expiring:
      c.statusMessage = "Expires in " ~ daysLeft(c, now).to!string ~ " day(s)";
      break;
    case CertificateStatus.expired:
      c.statusMessage = "Expired";
      break;
    case CertificateStatus.revoked:
      break;
    }
  }

  override protected void beforeRemove(Certificate c) {
    auto users = repos.destinations.findByCertificate(c.tenantId, c.id);
    ensureState(users.length == 0, "Certificate '" ~ c.name ~ "' is used by destination(s): "
        ~ users.map!(d => d.name).join(", "));
  }

  UsecaseResult revoke(TenantId tenantId, CertificateId id, UserId actor) {
    return transition(tenantId, id, actor, "revoked", (ref Certificate c) {
      ensureState(c.status != CertificateStatus.revoked, "Certificate '" ~ c.name ~ "' is already revoked");
      c.status = CertificateStatus.revoked;
      c.revokedAt = nowStdTime();
      c.statusMessage = "Revoked";
      events.log(c.tenantId, ConnectivityEventType.certificateRevoked, SourceType.certificate, c.id.value, c.name,
        "Certificate revoked (" ~ c.subjectDN ~ ")", "", 0, actor);
    });
  }

  UsecaseResult renew(TenantId tenantId, CertificateId id, int validDays, UserId actor) {
    return transition(tenantId, id, actor, "renewed", (ref Certificate c) {
      ensureState(c.status != CertificateStatus.revoked, "Revoked certificate '" ~ c.name ~ "' cannot be renewed");
      validate(validDays >= 1 && validDays <= 3650, "Validity must be between 1 and 3650 days");
      c.issuedAt = nowStdTime();
      c.expiresAt = c.issuedAt + validDays * stdTimeDay;
      refreshStatus(c);
      events.log(c.tenantId, ConnectivityEventType.certificateRenewed, SourceType.certificate, c.id.value, c.name,
        "Certificate renewed for " ~ validDays.to!string ~ " day(s)", "", 0, actor);
    });
  }
}
