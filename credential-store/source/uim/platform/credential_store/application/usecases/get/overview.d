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


import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
class GetOverviewUseCase {
  protected INamespaceRepository nsRepo;
  private ICredentialRepository credRepo;
  private IServiceBindingRepository bindingRepo;
  private IAuditLogRepository auditRepo;

  this(INamespaceRepository nsRepo, ICredentialRepository credRepo,
      IServiceBindingRepository bindingRepo, IAuditLogRepository auditRepo) {
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

///
unittest {
    auto namespaceRepository = new NamespaceRepository();
    auto credentialRepository = new CredentialRepository();
    auto serviceBindingRepository = new ServiceBindingRepository();
    auto auditLogRepository = new AuditLogRepository();
    auto usecase = new GetOverviewUseCase(namespaceRepository, credentialRepository, serviceBindingRepository, auditLogRepository);
    auto tenantId = TenantId("test-tenant");

    assert(usecase !is null);
}
