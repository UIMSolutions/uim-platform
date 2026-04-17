/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.entities.client;

// import uim.platform.docuimport uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct ClientLabel {
  string key;
  string value;
}

struct Client {
  ClientId id;
  TenantId tenantId;
  string name;
  string description;
  int documentQuota;
  int documentsProcessed;
  bool dataFeedbackEnabled;
  ClientLabel[] labels;
  long createdAt;
  long modifiedAt;
}
