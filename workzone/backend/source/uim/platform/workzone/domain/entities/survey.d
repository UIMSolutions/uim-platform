/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.survey;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A survey of a workspace. Questions are fixed once the survey is active.
struct Survey {
  mixin TenantEntity!SurveyId;

  WorkspaceId workspaceId;
  string workspaceName;
  string title;
  string description;
  UserId creatorId;
  string creatorName;
  SurveyStatus status = SurveyStatus.draft;
  SurveyQuestion[] questions;
  bool anonymous;
  bool allowMultipleResponses;
  int responseCount;
  string[] respondents; /// user ids (single response rule)
  long startsAt;
  long endsAt; /// 0 = open end; active surveys are closed by housekeeping
}
