/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.infrastructure.container;

import uim.platform.keystore.infrastructure.config;

// Repositories
import uim.platform.keystore.infrastructure.persistence.memory.keystores;
import uim.platform.keystore.infrastructure.persistence.memory.key_entries;
import uim.platform.keystore.infrastructure.persistence.memory.key_passwords;

// Domain services
import uim.platform.keystore.domain.services.keystore_search;

// Use Cases
import uim.platform.keystore.application.usecases.manage_keystores;
import uim.platform.keystore.application.usecases.manage_key_entries;
import uim.platform.keystore.application.usecases.manage_key_passwords;

// Controllers
import uim.platform.keystore.presentation.http.controllers.keystore;
import uim.platform.keystore.presentation.http.controllers.key_entry;
import uim.platform.keystore.presentation.http.controllers.key_password;
import uim.platform.keystore.presentation.http.controllers.health;

struct Container {
  // Repositories (driven adapters)
  MemoryKeystoreRepository   keystoreRepo;
  MemoryKeyEntryRepository   keyEntryRepo;
  MemoryKeyPasswordRepository keyPasswordRepo;

  // Domain services
  KeystoreSearchService keystoreSearch;

  // Use cases (application layer)
  ManageKeystoresUseCase   manageKeystores;
  ManageKeyEntriesUseCase  manageKeyEntries;
  ManageKeyPasswordsUseCase manageKeyPasswords;

  // Controllers (driving adapters)
  KeystoreController    keystoreController;
  KeyEntryController    keyEntryController;
  KeyPasswordController keyPasswordController;
  HealthController      healthController;
}

Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.keystoreRepo    = new MemoryKeystoreRepository();
  c.keyEntryRepo    = new MemoryKeyEntryRepository();
  c.keyPasswordRepo = new MemoryKeyPasswordRepository();

  // Domain services
  c.keystoreSearch = new KeystoreSearchService(c.keystoreRepo);

  // Application use cases
  c.manageKeystores    = new ManageKeystoresUseCase(c.keystoreRepo);
  c.manageKeyEntries   = new ManageKeyEntriesUseCase(c.keyEntryRepo);
  c.manageKeyPasswords = new ManageKeyPasswordsUseCase(c.keyPasswordRepo);

  // Presentation controllers
  c.keystoreController    = new KeystoreController(c.manageKeystores, c.keystoreSearch);
  c.keyEntryController    = new KeyEntryController(c.manageKeyEntries);
  c.keyPasswordController = new KeyPasswordController(c.manageKeyPasswords);
  c.healthController      = new HealthController("keystore");

  return c;
}
