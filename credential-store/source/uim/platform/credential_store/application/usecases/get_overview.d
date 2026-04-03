/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.use_cases.get_overview;

import uim.platform.credential_store.domain.ports.namespace_repository;
import uim.platform.credential_store.domain.ports.credential_repository;
import uim.platform.credential_store.domain.ports.service_binding_repository;
import uim.platform.credential_store.domain.ports.audit_log_repository;
import uim.platform.credential_store.domain.types;
import uim.platform.credential_store.application.dto;

class GetOverviewUseCase {
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
    foreach (ref c; allCreds) {
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
