/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage.translations;
// import uim.platform.portal.domain.entities.translation;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.translations;
// import uim.platform.portal.application.dto;


// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

// mixin(ShowModule!());

@safe:
class ManageTranslationsUseCase { // TODO: UIMUseCase {
  private TranslationRepository translationRepo;

  this(TranslationRepository translationRepo) {
    this.translationRepo = translationRepo;
  }

  CommandResult createTranslation(CreateTranslationRequest req) {
    if (req.fieldName.length == 0 || req.language.length == 0)
      return CommandResult(false, "", "Field name and language are required");

    Translation translation;
    translation.initEntity(req.tenantId);
    
    translation.resourceType = req.resourceType;
    translation.resourceId = req.resourceId;
    translation.fieldName = req.fieldName;
    translation.language = req.language;
    translation.value = req.value;
    
    translationRepo.save(translation);
    return CommandResult(true, translation.id.value, "Translation created successfully.");
  }

  Translation getTranslation(TenantId tenantId, TranslationId id) {
    return translationRepo.findById(tenantId, id);
  }

  Translation[] getTranslationsForResource(TenantId tenantId, string resourceType,
    string resourceId, string language = "") {
    return translationRepo.findByResource(tenantId, resourceType, resourceId, language);
  }

  Translation[] listTranslations(TenantId tenantId, string language, size_t offset = 0,
    size_t limit = 100) {
    return translationRepo.findByLanguage(tenantId, language, offset, limit);
  }

  CommandResult updateTranslation(UpdateTranslationRequest req) {
    if (!translationRepo.existsById(req.tenantId, req.translationId))
      return CommandResult(false, "", "Translation not found");

    auto translation = translationRepo.findById(req.tenantId, req.translationId) ;
    translation.value = req.value;
    translation.updatedAt = currentTimestamp();

    translationRepo.update(translation);
    return CommandResult(true, translation.id.value, "Translation updated successfully.");
  }

  CommandResult deleteTranslation(TenantId tenantId, TranslationId id) {
    auto trans = translationRepo.findById(tenantId, id);
    if (trans.isNull)
      return CommandResult(false, "", "Translation not found");

    translationRepo.remove(trans);
    return CommandResult(true, trans.id.value, "Translation deleted successfully.");
  }

  CommandResult deleteTranslationsForResource(TenantId tenantId, string resourceType, string resourceId) {
    translationRepo.removeByResource(tenantId, resourceType, resourceId);
    return CommandResult(true, "", "Translations deleted successfully.");
  }
}
