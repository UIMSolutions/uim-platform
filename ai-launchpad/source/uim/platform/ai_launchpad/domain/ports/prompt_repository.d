/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.prompts;

import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.domain.entities.prompt : Prompt;

interface IPromptRepository {
  void save(Prompt p);
  Prompt findById(PromptId id);
  Prompt[] findByCollection(PromptCollectionId collectionId);
  Prompt[] findByStatus(PromptStatus status);
  Prompt[] findAll();
  void remove(PromptId id);
}
