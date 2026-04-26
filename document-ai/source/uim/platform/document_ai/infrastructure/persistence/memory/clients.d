/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.clients;

// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.client;
// import uim.platform.document_ai.domain.ports.repositories.clients;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class MemoryClientRepository : TenantRepository!(Client, ClientId), ClientRepository {

  // TODO

}
