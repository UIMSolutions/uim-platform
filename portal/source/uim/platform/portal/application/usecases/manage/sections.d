/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage.sections;
// import uim.platform.portal.domain.entities.section;
// import uim.platform.portal.domain.entities.page;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.sections;
// import uim.platform.portal.domain.ports.repositories.pages;
// import uim.platform.portal.application.dto;

 
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

// mixin(ShowModule!());

@safe:
class ManageSectionsUseCase { // TODO: UIMUseCase {
  private SectionRepository sectionRepo;
  private PageRepository pageRepo;

  this(SectionRepository sectionRepo, PageRepository pageRepo) {
    this.sectionRepo = sectionRepo;
    this.pageRepo = pageRepo;
  }

  SectionResponse createSection(CreateSectionRequest req) {
    if (pageRepo.existsById(req.pageId))
      return SectionResponse("", "Page not found");

    PortalSection section;
    section.initEntity(req.tenantId);
    with (section) {
      id = id;
      pageId = req.pageId;
      title = req.title;
      sortOrder = req.sortOrder;
      visible = req.visible;
      columns = req.columns > 0 ? req.columns : 3;
    }

    page.sectionIds ~= id;
    page.updatedAt = now;
    pageRepo.save(page);

    return SectionResponse(id.value, "");
  }

  PortalSection getSection(SectionId id) {
    return sectionRepo.find(tenantId, id);
  }

  PortalSection[] listSections(PageId pageId) {
    return sectionRepo.findByPage(pageId);
  }

  CommandResult updateSection(UpdateSectionRequest req) {
    auto section = sectionRepo.findById(req.sectionId);
    if (section.isNull)
      return CommandResult(false, "", "Section not found");

    with (section) {
      title = req.title.length > 0 ? req.title : title;
      sortOrder = req.sortOrder;
      visible = req.visible;
      columns = req.columns > 0 ? req.columns : columns;
      updatedAt = currentTimestamp();
    }
    sectionRepo.update(section);
    return CommandResult(true, req.sectionId.value, "");
  }

  CommandResult deleteSection(SectionId sectionId, PageId pageId) {
    if (!sectionRepo.existsById(sectionId))
      return CommandResult(false, "", "Section not found")  ;

    sectionRepo.remove(sectionId);

    if (pageRepo.existsById(pageId)) {
      auto page = pageRepo.findById(pageId);
      page.sectionIds = page.sectionIds.filter!(s => s != sectionId).array.toJson;
      page.updatedAt = currentTimestamp();
      pageRepo.update(page);
    }

    return CommandResult(true, sectionId.value, "");
  }
}
