/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.enumerations.collaboration;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Kind of workspace.
enum WorkspaceType {
  team,
  project,
  department,
  public_,
  external,
}

/// Lifecycle of a workspace. Only active workspaces accept new content.
enum WorkspaceStatus {
  active,
  archived,
  suspended,
}

/// Role of a member inside a workspace (ordered: viewer < ... < owner).
enum MemberRole {
  viewer,
  contributor,
  admin,
  owner,
}

/// Kind of content item.
enum ContentType {
  blogPost,
  wikiPage,
  announcement,
  document,
}

/// Lifecycle of a content item.
enum ContentStatus {
  draft,
  published,
  archived,
}

/// Lifecycle of a knowledge base article: draft → review → published → archived.
enum KBArticleStatus {
  draft,
  review,
  published,
  archived,
}

/// Lifecycle of a forum topic (pinned / locked are flags).
enum ForumTopicStatus {
  open,
  closed,
  archived,
}

/// Lifecycle of a survey: draft → active → closed → archived.
enum SurveyStatus {
  draft,
  active,
  closed,
  archived,
}

/// Kind of survey question.
enum QuestionType {
  singleChoice,
  multipleChoice,
  freeText,
  rating,
  scale,
}

/// True for questions that need answer options.
bool needsOptions(QuestionType t) pure nothrow {
  return t == QuestionType.singleChoice || t == QuestionType.multipleChoice;
}

/// Lifecycle of a calendar event (scheduled → ongoing → completed driven by time).
enum EventStatus {
  scheduled,
  ongoing,
  completed,
  cancelled,
}

///
unittest {
  assert(MemberRole.owner > MemberRole.admin && MemberRole.viewer < MemberRole.contributor);
  assert(QuestionType.multipleChoice.needsOptions && !QuestionType.freeText.needsOptions);
  assert(parseEnum!WorkspaceType("public", WorkspaceType.team) == WorkspaceType.public_);
  assert(enumText(WorkspaceType.public_) == "public");
}
