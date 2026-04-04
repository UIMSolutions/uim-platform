/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage.sections;

import uim.platform.portal.domain.entities.section;
import uim.platform.portal.domain.entities.page;
import uim.platform.portal.domain.types;
import uim.platform.portal.domain.ports.repositories.sections;
import uim.platform.portal.domain.ports.repositories.pages;
import uim.platform.portal.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;
// import std.algorithm : filter;
// import std.array : array;

class ManageSectionsUseCase : UIMUseCase{
  private SectionRepository sectionRepo;
  private PageRepository pageRepo;

  this(SectionRepository sectionRepo, PageRepository pageRepo) {
    this.sectionRepo = sectionRepo;
    this.pageRepo = pageRepo;
  }

  SectionResponse createSection(CreateSectionRequest req) {
    auto page = pageRepo.findById(req.pageId);
    if (page == Page.init)
      return SectionResponse("", "Page not found");

    auto now = Clock.currStdTime();
    auto id = randomUUID().toString();
    auto section = Section(id, req.pageId, req.tenantId, req.title, [], // tileIds
      req.sortOrder, req.visible, req.columns > 0 ? req.columns : 3, now, now,);
    sectionRepo.save(section);

    page.sectionIds ~= id;
    page.updatedAt = now;
    pageRepo.update(page);

    return SectionResponse(id, "");
  }

  Section getSection(SectionId id) {
    return sectionRepo.findById(id);
  }

  Section[] listSections(PageId pageId) {
    return sectionRepo.findByPage(pageId);
  }

  string updateSection(UpdateSectionRequest req) {
    auto section = sectionRepo.findById(req.sectionId);
    if (section == Section.init)
      return "Section not found";

    section.title = req.title.length > 0 ? req.title : section.title;
    section.sortOrder = req.sortOrder;
    section.visible = req.visible;
    section.columns = req.columns > 0 ? req.columns : section.columns;
    section.updatedAt = Clock.currStdTime();
    sectionRepo.update(section);
    return "";
  }

  string deleteSection(SectionId sectionId, PageId pageId) {
    auto section = sectionRepo.findById(sectionId);
    if (section == Section.init)
      return "Section not found";

    sectionRepo.remove(sectionId);

    auto page = pageRepo.findById(pageId);
    if (page != Page.init) {
      page.sectionIds = page.sectionIds.filter!(s => s != sectionId).array;
      page.updatedAt = Clock.currStdTime();
      pageRepo.update(page);
    }

    return "";
  }
}
