/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.use_cases.get_capabilities;

import uim.platform.document_ai.application.dto;

class GetCapabilitiesUseCase : UIMUseCase {
  CapabilitiesResponse getCapabilities() {
    CapabilitiesResponse r;
    r.extraction = true;
    r.classification = true;
    r.enrichment = true;
    r.templateMatching = true;
    r.training = true;
    r.dataFeedback = true;
    r.multitenant = true;
    r.supportedFileTypes = ["pdf", "png", "jpeg", "tiff", "xlsx", "docx"];
    r.supportedLanguages = ["en", "de", "fr", "es", "it", "pt", "nl", "ja", "zh", "ko", "ar", "hi"];
    r.supportedDocumentTypes = [
      "invoice", "purchase_order", "payment_advice", "delivery_note",
      "credit_memo", "bank_statement", "receipt", "contract",
      "customs_declaration", "bill_of_lading", "letter_of_credit", "general", "custom"
    ];
    r.apiVersion = "v1";
    return r;
  }
}
