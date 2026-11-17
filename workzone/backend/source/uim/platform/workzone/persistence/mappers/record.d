/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.persistence.mappers.record;

import uim.platform.workzone;

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

///
unittest {
  mixin(ShowTest!("RecordMapper"));

  auto ws = Workspace(TenantId("t1"));
  ws.name = "Sales EMEA";
  ws.alias_ = "sales-emea";
  ws.type = WorkspaceType.public_;
  ws.members = [WorkspaceMember("jane", "Jane", MemberRole.owner, 5)];
  auto record = RecordMapper!Workspace.toRecord(ws);
  assert(record["alias"].get!string == "sales-emea" && record["type"].get!string == "public");
  assert(record["members"][0]["role"].get!string == "owner");
  assert(record["createdAt"].type == Json.Type.int_);
  assert(RecordMapper!Workspace.fromRecord(record) == ws);

  auto theme = Theme(TenantId("t1"));
  theme.baseTheme = BaseTheme.sapHorizonDark;
  auto tr = RecordMapper!Theme.toRecord(theme);
  assert(tr["baseTheme"].get!string == "sap_horizon_dark");
  assert(RecordMapper!Theme.fromRecord(tr) == theme);

  auto tpl = PageTemplate(TenantId("t1"));
  tpl.sections = [TemplateSection("main", "Main", 3, "grid", 0, [WidgetSize.medium, WidgetSize.large])];
  assert(RecordMapper!PageTemplate.fromRecord(RecordMapper!PageTemplate.toRecord(tpl)) == tpl);

  auto survey = Survey(TenantId("t1"));
  survey.questions = [SurveyQuestion("q1", "Happy?", QuestionType.rating, null, true, 1)];
  auto sr = RecordMapper!Survey.toRecord(survey);
  assert(sr["questions"][0]["required"].get!bool);
  assert(RecordMapper!Survey.fromRecord(sr) == survey);
}
