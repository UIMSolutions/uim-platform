/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.survey;

import uim.platform.workzone.domain.types;

/// A survey or poll within a workspace.
struct Survey {
  mixin TenantEntity!(SurveyId);

  WorkspaceId workspaceId;
  string title;
  string description;
  UserId creatorId;
  string creatorName;
  SurveyStatus status = SurveyStatus.draft;
  SurveyQuestion[] questions;
  bool anonymous;
  bool allowMultipleResponses;
  int responseCount;
  long startsAt;
  long endsAt;

  Json toJson() const {
    return Json.entityToJson
      .set("workspaceId", workspaceId.value)
      .set("title", title)
      .set("description", description)
      .set("creatorId", creatorId.value)
      .set("creatorName", creatorName)
      .set("status", status.toString())
      .set("questions", questions.map!(q => q.toJson()).array)
      .set("anonymous", anonymous)
      .set("allowMultipleResponses", allowMultipleResponses)
      .set("responseCount", responseCount)
      .set("startsAt", startsAt)
      .set("endsAt", endsAt);
  }
}

/// A single question within a survey.
struct SurveyQuestion {
  string questionId;
  string text;
  QuestionType questionType = QuestionType.singleChoice;
  string[] options;
  bool required_;
  int sortOrder;

  Json toJson() const {
    return Json.emptyObject
      .set("questionId", questionId)
      .set("text", text)
      .set("questionType", questionType.toString())
      .set("options", options.array)
      .set("required", required_)
      .set("sortOrder", sortOrder);
  }
}
