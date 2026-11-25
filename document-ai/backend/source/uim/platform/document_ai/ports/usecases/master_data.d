/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of clients, document types and enrichment data.
module uim.platform.document_ai.ports.usecases.master_data;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

interface IManageClients : IManageResource!(Client, ClientId, ClientInput) {
  /// Documents per client id.
  long[string] documentCounts(TenantId t);
}

interface IManageDocumentTypes : IManageResource!(DocumentType, DocumentTypeId, DocumentTypeInput) {
}

interface IManageEnrichmentData : IManageResource!(EnrichmentData, EnrichmentDataId, EnrichmentDataInput) {
}
