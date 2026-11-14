/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.ports.usecases.certificates;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Maintain the certificate store. Certificates used by destinations cannot be deleted.
interface IManageCertificatesUseCase : IManageResource!(Certificate, CertificateId,
    CreateCertificateRequest, UpdateCertificateRequest) {
  UsecaseResult revoke(TenantId tenantId, CertificateId id, UserId actor);
  /// Extend the validity by `validDays` from now (renewal with the same key).
  UsecaseResult renew(TenantId tenantId, CertificateId id, int validDays, UserId actor);
}
