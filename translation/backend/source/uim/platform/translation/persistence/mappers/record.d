/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.persistence.mappers.record;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Generic mapper between entities and database records, driven by
/// compile-time reflection (see helpers.codec). Records keep timestamps as raw
/// std-time numbers and enums by name; unknown or missing fields fall back to
/// the entity defaults, so older snapshots stay readable.
struct RecordMapper(TEntity) {
  static Json toRecord(const TEntity entity) {
    return encode(entity, false);
  }

  static TEntity fromRecord(Json record) {
    return decode!TEntity(record);
  }
}

alias ProjectMapper = RecordMapper!TranslationProject;
alias ProjectTextMapper = RecordMapper!ProjectText;
alias GlossaryEntryMapper = RecordMapper!GlossaryEntry;
alias JobMapper = RecordMapper!TranslationJob;

///
unittest {
  mixin(ShowTest!("RecordMapper"));

  auto p = TranslationProject(TenantId("t1"));
  p.name = "Shop";
  p.targetLanguages = ["de", "fr"];
  p.provider = TranslationProvider.companyMltr;
  p.status = ProjectStatus.inProgress;
  auto record = ProjectMapper.toRecord(p);
  assert(record["provider"].get!string == "companyMltr");
  assert(record["targetLanguages"][1].get!string == "fr");
  assert(record["createdAt"].type == Json.Type.int_);
  assert(ProjectMapper.fromRecord(record) == p);

  auto t = ProjectText(TenantId("t1"));
  t.projectId = p.id;
  t.name = "BUTTON_SAVE";
  t.translations = [TextTranslation("de", "Speichern", TranslationProvider.mltr, 96, 0, true, 42)];
  auto back = ProjectTextMapper.fromRecord(ProjectTextMapper.toRecord(t));
  assert(back == t && back.translations[0].reviewed);

  // older snapshots without new fields stay readable
  auto j = JobMapper.fromRecord(parseJsonString(`{"id": "j1", "tenantId": "t1", "status": "completed"}`));
  assert(j.status == JobStatus.completed && j.contentType == "text/plain");
}
