/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Value objects embedded in the aggregates (exchanged as OData complex types).
module uim.platform.workzone.domain.types.values;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// An ordered key/value pair (widget parameters).
struct KeyValue {
  string key;
  string value;
}

/// Membership of a user in a workspace.
struct WorkspaceMember {
  string userId;
  string displayName;
  MemberRole role = MemberRole.contributor;
  long joinedAt;
}

/// A section of a page template (layout grid for widgets).
struct TemplateSection {
  string sectionId;
  string title;
  int columns = 1;
  string layoutType = "grid"; /// grid | list | tabs
  int sortOrder;
  WidgetSize[] allowedWidgetSizes;
}

/// A question of a survey.
struct SurveyQuestion {
  string questionId;
  string text;
  QuestionType questionType = QuestionType.singleChoice;
  string[] options;
  bool required_;
  int sortOrder;
}

/// Value of `key` in a list of pairs ("" if missing).
string valueOf(const KeyValue[] pairs, string key) {
  foreach (p; pairs)
    if (p.key == key)
      return p.value;
  return "";
}

///
unittest {
  assert(valueOf([KeyValue("filter", "open")], "filter") == "open");
  assert(valueOf([KeyValue("filter", "open")], "x") == "");
}
