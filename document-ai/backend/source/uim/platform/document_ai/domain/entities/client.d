/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A client: a sub-tenant that separates documents, schemas and master
/// data of one organizational unit and limits the documents it may process.
module uim.platform.document_ai.domain.entities.client;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct Client {
  mixin TenantEntity!ClientId;

  string name;
  string description;
  int documentQuota; /// documents the client may upload; 0 = unlimited
  bool dataFeedbackEnabled = true; /// confirmed documents may be used for training

  /// True if one more document fits into the quota.
  bool admits(long documents) const {
    return documentQuota <= 0 || documents < documentQuota;
  }

  void validate() const {
    requireId(id.value, "Client ID");
    requireText(name, "Name");
    requireMaxLength(name, 200, "Name");
    requireMaxLength(description, 2000, "Description");
    requireRange(documentQuota, 0, 100_000_000, "Document quota");
  }
}

///
unittest {
  Client c;
  c.id = ClientId("c1");
  c.name = "Finance";
  c.validate();
  assert(c.admits(1_000_000));
  c.documentQuota = 2;
  assert(c.admits(1) && !c.admits(2));
  c.documentQuota = -1;
  assert(failsWith(DaiErrorKind.invalid, () { c.validate(); }));
}
