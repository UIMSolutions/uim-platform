/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document AI service (SAP Document Information Extraction style):
/// document upload and automated extraction of header fields and line
/// items with confidence scores, review and correction, confirmation,
/// extraction schemas and their fields, templates, document types,
/// enrichment data matching, model training jobs and multi-client quotas.
///
/// Layers (hexagonal / clean architecture):
///   domain → ports → application → persistence / infrastructure → presentation
module uim.platform.document_ai;

public {
  import uim.platform.service;
  import uim.platform.document_ai.domain;
  import uim.platform.document_ai.ports;
  import uim.platform.document_ai.application;
  import uim.platform.document_ai.persistence;
  import uim.platform.document_ai.infrastructure;
  import uim.platform.document_ai.presentation;
}
