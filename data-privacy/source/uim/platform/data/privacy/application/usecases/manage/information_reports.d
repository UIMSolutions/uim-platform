/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.information_reports;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageInformationReportsUseCase : UIMUseCase {
  private InformationReportRepository repo;
  private DataSubjectRepository subjectRepo;

  this(InformationReportRepository repo, DataSubjectRepository subjectRepo) {
    this.repo = repo;
    this.subjectRepo = subjectRepo;
  }

  CommandResult createReport(CreateInformationReportRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");
    if (req.dataSubjectid.isEmpty)
      return CommandResult("", "Data subject ID is required");

    auto subject = subjectRepo.findById(req.dataSubjectId, req.tenantId);
    if (subject is null)
      return CommandResult("", "Data subject not found");

    auto now = Clock.currStdTime();
    auto r = InformationReport();
    r.id = randomUUID().toString();
    r.tenantId = req.tenantId;
    r.dataSubjectId = req.dataSubjectId;
    r.subjectRole = subject.subjectType;
    r.requestedBy = req.requestedBy;
    r.status = InformationReportStatus.requested;
    r.format = parseExportFormat(req.format);
    r.targetSystems = req.targetSystems;
    r.categories = req.categories;
    r.reason = req.reason;
    r.requestedAt = now;

    repo.save(r);
    return CommandResult(r.id, "");
  }

  InformationReport* getReport(InformationReportId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  InformationReport[] listReports(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  InformationReport[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  CommandResult updateStatus(UpdateInformationReportStatusRequest req) {
    auto r = repo.findById(req.id, req.tenantId);
    if (r is null)
      return CommandResult("", "Information report not found");

    r.status = req.status;
    if (req.downloadUrl.length > 0) r.downloadUrl = req.downloadUrl;
    if (req.totalRecords > 0) r.totalRecords = req.totalRecords;
    if (req.status == InformationReportStatus.completed) {
      r.generatedAt = Clock.currStdTime();
      r.expiresAt = r.generatedAt + 7 * 24 * 60 * 60 * 10_000_000L; // 7 days
    }

    repo.update(*r);
    return CommandResult(r.id, "");
  }

  void deleteReport(InformationReportId id, TenantId tenantId) {
    repo.remove(id, tenantId);
  }

  private ExportFormat parseExportFormat(string s) {
    switch (s) {
      case "json": return ExportFormat.json;
      case "xml": return ExportFormat.xml;
      case "csv": return ExportFormat.csv;
      default: return ExportFormat.pdf;
    }
  }
}
