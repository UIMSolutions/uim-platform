/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.infrastructure.container;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:
struct Container {
  // Repositories (driven adapters)
  KeystoreRepository keystoreRepo;
  KeyEntryRepository keyEntryRepo;
  KeyPasswordRepository keyPasswordRepo;

  // Domain services
  KeystoreSearchService keystoreSearch;

  // Use cases (application layer)
  ManageKeystoresUseCase manageKeystores;
  ManageKeyEntriesUseCase manageKeyEntries;
  ManageKeyPasswordsUseCase manageKeyPasswords;

  // Controllers (driving adapters)
  KeystoreController keystoreController;
  KeyEntryController keyEntryController;
  KeyPasswordController keyPasswordController;
  HealthController healthController;
}

Container buildContainer(SrvConfig config) {
  Container c;

  // Infrastructure adapters
  c.keystoreRepo = new KeystoreRepository();
  c.keyEntryRepo = new KeyEntryRepository();
  c.keyPasswordRepo = new KeyPasswordRepository();

  // Domain services
  c.keystoreSearch = new KeystoreSearchService(c.keystoreRepo);

  // Application use cases
  c.manageKeystores = new ManageKeystoresUseCase(c.keystoreRepo);
  c.manageKeyEntries = new ManageKeyEntriesUseCase(c.keyEntryRepo);
  c.manageKeyPasswords = new ManageKeyPasswordsUseCase(c.keyPasswordRepo);

  // Presentation controllers
  c.keystoreController = new KeystoreController(c.manageKeystores, c.keystoreSearch);
  c.keyEntryController = new KeyEntryController(c.manageKeyEntries);
  c.keyPasswordController = new KeyPasswordController(c.manageKeyPasswords);
  c.healthController = new HealthController("keystore");

  return c;
}
