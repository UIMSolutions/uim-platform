/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.surveys;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.survey;
import uim.platform.workzone.domain.ports.repositories.surveys;
import uim.platform.workzone.application.dto;

class ManageSurveysUseCase : UIMUseCase {
  private SurveyRepository repo;

  this(SurveyRepository repo) {
    this.repo = repo;
  }

  CommandResult createSurvey(CreateSurveyRequest req) {
    if (req.title.length == 0)
      return CommandResult(false, "", "Survey title is required");

    auto now = Clock.currStdTime();
    auto s = Survey();
    s.id = randomUUID();
    s.workspaceId = req.workspaceId;
    s.tenantId = req.tenantId;
    s.title = req.title;
    s.description = req.description;
    s.creatorId = req.creatorId;
    s.creatorName = req.creatorName;
    s.status = SurveyStatus.draft;
    s.questions = req.questions;
    s.anonymous = req.anonymous;
    s.allowMultipleResponses = req.allowMultipleResponses;
    s.startsAt = req.startsAt;
    s.endsAt = req.endsAt;
    s.createdAt = now;
    s.updatedAt = now;

    repo.save(s);
    return CommandResult(s.id, "");
  }

  Survey* getSurvey(SurveyId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Survey[] listByWorkspace(WorkspaceId workspacetenantId, id tenantId) {
    return repo.findByWorkspace(workspacetenantId, id);
  }

  CommandResult updateSurvey(UpdateSurveyRequest req) {
    auto s = repo.findById(req.id, req.tenantId);
    if (s is null)
      return CommandResult(false, "", "Survey not found");

    if (req.title.length > 0)
      s.title = req.title;
    if (req.description.length > 0)
      s.description = req.description;
    s.status = req.status;
    s.updatedAt = Clock.currStdTime();

    repo.update(*s);
    return CommandResult(s.id, "");
  }

  CommandResult deleteSurvey(SurveyId tenantId, id tenantId) {
    auto s = repo.findById(tenantId, id);
    if (s is null)
      return CommandResult(false, "", "Survey not found");

    repo.remove(tenantId, id);
    return CommandResult(true, id.toString, "");
  }
}
