/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage.translations;

import uim.platform.portal.domain.entities.translation;
import uim.platform.portal.domain.types;
import uim.platform.portal.domain.ports.repositories.translations;
import uim.platform.portal.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;

class ManageTranslationsUseCase : UIMUseCase {
  private TranslationRepository translationRepo;

  this(TranslationRepository translationRepo) {
    this.translationRepo = translationRepo;
  }

  TranslationResponse createTranslation(CreateTranslationRequest req) {
    if (req.fieldName.length == 0 || req.language.length == 0)
      return TranslationResponse("", "Field name and language are required");

    auto now = Clock.currStdTime();
    auto id = randomUUID().toString();
    auto translation = Translation(id, req.tenantId, req.resourceType,
      req.resourceId, req.fieldName, req.language, req.value, now, now,);
    translationRepo.save(translation);
    return TranslationResponse(id, "");
  }

  Translation getTranslation(TranslationId id) {
    return translationRepo.findById(id);
  }

  Translation[] getTranslationsForResource(string resourceType,
    string resourceId, string language = "") {
    return translationRepo.findByResource(resourceType, resourceId, language);
  }

  Translation[] listTranslations(TenantId tenantId, string language, uint offset = 0,
    uint limit = 100) {
    return translationRepo.findByLanguage(tenantId, language, offset, limit);
  }

  string updateTranslation(UpdateTranslationRequest req) {
    auto translation = translationRepo.findById(req.translationId);
    if (translation == Translation.init)
      return "Translation not found";

    translation.value = req.value;
    translation.updatedAt = Clock.currStdTime();
    translationRepo.update(translation);
    return "";
  }

  string deleteTranslation(TranslationId id) {
    auto translation = translationRepo.findById(id);
    if (translation == Translation.init)
      return "Translation not found";

    translationRepo.remove(id);
    return "";
  }

  string deleteTranslationsForResource(string resourceType, string resourceId) {
    translationRepo.removeByResource(resourceType, resourceId);
    return "";
  }
}
