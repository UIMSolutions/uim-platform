/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.usecases.encrypt_dek;
// import uim.platform.credential_store.domain.ports.repositories.credentials;
// import uim.platform.credential_store.domain.ports.repositories.keyring_versions;
// import uim.platform.credential_store.domain.entities.credential;
// import uim.platform.credential_store.domain.entities.keyring_version;
// import uim.platform.credential_store.domain.services.encryption_service;


import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
interface IEncryptDekUseCase { 
  
  GenerateDekResponse generate(GenerateDekRequest r);
  EncryptDekResponse encrypt(EncryptDekRequest r);
  DecryptDekResponse decrypt(DecryptDekRequest r);

}
