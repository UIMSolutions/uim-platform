/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port for low-level data stores: the document store of
/// uim-platform:service (collection → tenant → key → JSON document).
/// Implementations: memory, JSON file (uim-platform:service), MongoDB (persistence.storages).
module uim.platform.authorization.ports.storages;

public import uim.platform.service.ports.storages.documents : IDocumentStore;
