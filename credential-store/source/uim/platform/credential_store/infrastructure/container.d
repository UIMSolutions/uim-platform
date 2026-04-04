/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.container;

import uim.platform.credential_store.infrastructure.config;

// Repositories
import uim.platform.credential_store.infrastructure.persistence.memory.namespaces;
import uim.platform.credential_store.infrastructure.persistence.memory.credentials;
import uim.platform.credential_store.infrastructure.persistence.memory.keyring_versions;
import uim.platform.credential_store.infrastructure.persistence.memory.service_bindings;
import uim.platform.credential_store.infrastructure.persistence.memory.audit_logs;

// Use Cases
import uim.platform.credential_store.application.usecases.manage.namespaces;
import uim.platform.credential_store.application.usecases.manage.credentials;
import uim.platform.credential_store.application.usecases.manage.keyrings;
import uim.platform.credential_store.application.usecases.encrypt_dek;
import uim.platform.credential_store.application.usecases.manage.service_bindings;
import uim.platform.credential_store.application.usecases.get_audit_logs;
import uim.platform.credential_store.application.usecases.get_overview;

// Controllers
import uim.platform.credential_store.presentation.http.controllers.namespace;
import uim.platform.credential_store.presentation.http.controllers.credential;
import uim.platform.credential_store.presentation.http.controllers.keyring;
import uim.platform.credential_store.presentation.http.controllers.encryption;
import uim.platform.credential_store.presentation.http.controllers.binding;
import uim.platform.credential_store.presentation.http.controllers.audit;
import uim.platform.credential_store.presentation.http.controllers.overview;
import uim.platform.credential_store.presentation.http.controllers.health;

struct Container {
  // Repositories (driven adapters)
  MemoryNamespaceRepository nsRepo;
  MemoryCredentialRepository credRepo;
  MemoryKeyringVersionRepository versionRepo;
  MemoryServiceBindingRepository bindingRepo;
  MemoryAuditLogRepository auditRepo;

  // Use cases (application layer)
  ManageNamespacesUseCase manageNamespaces;
  ManageCredentialsUseCase manageCredentials;
  ManageKeyringsUseCase manageKeyrings;
  EncryptDekUseCase encryptDek;
  ManageServiceBindingsUseCase manageBindings;
  GetAuditLogsUseCase getAuditLogs;
  GetOverviewUseCase getOverview;

  // Controllers (driving adapters)
  NamespaceController namespaceController;
  CredentialController credentialController;
  KeyringController keyringController;
  EncryptionController encryptionController;
  BindingController bindingController;
  AuditController auditController;
  OverviewController overviewController;
  HealthController healthController;
}

Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.nsRepo = new MemoryNamespaceRepository();
  c.credRepo = new MemoryCredentialRepository();
  c.versionRepo = new MemoryKeyringVersionRepository();
  c.bindingRepo = new MemoryServiceBindingRepository();
  c.auditRepo = new MemoryAuditLogRepository();

  // Application use cases
  c.manageNamespaces = new ManageNamespacesUseCase(c.nsRepo);
  c.manageCredentials = new ManageCredentialsUseCase(c.credRepo);
  c.manageKeyrings = new ManageKeyringsUseCase(c.credRepo, c.versionRepo);
  c.encryptDek = new EncryptDekUseCase(c.credRepo, c.versionRepo);
  c.manageBindings = new ManageServiceBindingsUseCase(c.bindingRepo);
  c.getAuditLogs = new GetAuditLogsUseCase(c.auditRepo);
  c.getOverview = new GetOverviewUseCase(c.nsRepo, c.credRepo, c.bindingRepo, c.auditRepo);

  // Presentation controllers
  c.namespaceController = new NamespaceController(c.manageNamespaces);
  c.credentialController = new CredentialController(c.manageCredentials);
  c.keyringController = new KeyringController(c.manageKeyrings);
  c.encryptionController = new EncryptionController(c.encryptDek);
  c.bindingController = new BindingController(c.manageBindings);
  c.auditController = new AuditController(c.getAuditLogs);
  c.overviewController = new OverviewController(c.getOverview);
  c.healthController = new HealthController("credential-store");

  return c;
}
