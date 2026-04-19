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

// import std.uuid;
// import std.datetime.systime : Clock;
// import std.algorithm : filter;
// import std.array : array;
import uim.platform.portal.application.dto;
import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

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

    auto now = Clock.currStdTime();
    auto id = randomUUID();
    PortalSection section;
    with (section) {
      id = id;
      pageId = req.pageId;
      tenantId = req.tenantId;
      title = req.title;
      sortOrder = req.sortOrder;
      visible = req.visible;
      columns = req.columns > 0 ? req.columns : 3;
      createdAt = now;
      updatedAt = now;
    }

    page.sectionIds ~= id;
    page.updatedAt = now;
    pageRepo.save(page);

    return SectionResponse(id, "");
  }

  PortalSection getSection(SectionId id) {
    return sectionRepo.findById(id);
  }

  PortalSection[] listSections(PageId pageId) {
    return sectionRepo.findByPage(pageId);
  }

  string updateSection(UpdateSectionRequest req) {
    if (!sectionRepo.existsById(req.sectionId))
      return "Section not found";

    auto section = sectionRepo.findById(req.sectionId);
    with (section) {
      title = req.title.length > 0 ? req.title : title;
      sortOrder = req.sortOrder;
      visible = req.visible;
      columns = req.columns > 0 ? req.columns : columns;
      updatedAt = Clock.currStdTime();
    }
    sectionRepo.update(section);
    return "";
  }

  string deleteSection(SectionId sectionId, PageId pageId) {
    if (!sectionRepo.existsById(sectionId))
      return "Section not found";

    sectionRepo.remove(sectionId);

    if (pageRepo.existsById(pageId)) {
      auto page = pageRepo.findById(pageId);
      page.sectionIds = page.sectionIds.filter!(s => s != sectionId).array;
      page.updatedAt = Clock.currStdTime();
      pageRepo.update(page);
    }

    return "";
  }
}
