/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.usecases.get.overview;

// import uim.platform.credential_store.domain.ports.repositories.namespaces;
// import uim.platform.credential_store.domain.ports.repositories.credentials;
// import uim.platform.credential_store.domain.ports.repositories.service_bindings;
// import uim.platform.credential_store.domain.ports.repositories.audit_logs;
// import uim.platform.credential_store.domain.types;
// import uim.platform.credential_store.application.dto;
import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
class GetOverviewUseCase { // TODO: UIMUseCase {
  private NamespaceRepository nsRepo;
  private CredentialRepository credRepo;
  private ServiceBindingRepository bindingRepo;
  private AuditLogRepository auditRepo;

  this(NamespaceRepository nsRepo, CredentialRepository credRepo,
      ServiceBindingRepository bindingRepo, AuditLogRepository auditRepo) {
    this.nsRepo = nsRepo;
    this.credRepo = credRepo;
    this.bindingRepo = bindingRepo;
    this.auditRepo = auditRepo;
  }

  OverviewSummary getSummary(TenantId tenantId) {
    OverviewSummary s;
    s.totalNamespaces = nsRepo.countByTenant(tenantId);
    s.totalCredentials = credRepo.countByTenant(tenantId);

    // Count by type
    auto allCreds = credRepo.findByTenant(tenantId);
    foreach (c; allCreds) {
      final switch (c.type) {
      case CredentialType.password:
        s.totalPasswords++;
        break;
      case CredentialType.key:
        s.totalKeys++;
        break;
      case CredentialType.keyring:
        s.totalKeyrings++;
        break;
      }
    }

    s.totalBindings = bindingRepo.countByTenant(tenantId);
    s.totalAuditEntries = auditRepo.countByTenant(tenantId);
    return s;
  }
}
