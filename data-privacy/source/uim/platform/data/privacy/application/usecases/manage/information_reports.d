/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.information_reports;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageInformationReportsUseCase { // TODO: UIMUseCase {
  private InformationReportRepository repo;
  private DataSubjectRepository subjectRepo;

  this(InformationReportRepository repo, DataSubjectRepository subjectRepo) {
    this.repo = repo;
    this.subjectRepo = subjectRepo;
  }

  CommandResult createReport(CreateInformationReportRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    if (req.subjectId.isEmpty)
      return CommandResult(false, "", "Data subject ID is required");

    auto subject = subjectRepo.findById(req.tenantId, req.subjectId);
    if (subject.isNull)
      return CommandResult(false, "", "Data subject not found");

    InformationReport report;
    report.initEntity(req.tenantId, req.requestedBy);

    report.dataSubjectId = req.subjectId;
    report.subjectRole = subject.subjectType;
    report.status = InformationReportStatus.requested;
    report.format = req.format.to!ExportFormat;
    report.targetSystems = req.targetSystems;
    report.categories = req.categories.map!(c => c.toPersonalDataCategory).array;
    report.reason = req.reason;
    report.requestedAt = report.createdAt;

    repo.save(report);
    return CommandResult(true, report.id.value, "");
  }

  InformationReport getReport(TenantId tenantId, InformationReportId reportId ) {
    return repo.findById(tenantId, reportId);
  }

  InformationReport[] listReports(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  InformationReport[] listReports(TenantId tenantId, DataSubjectId subjectId) {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  CommandResult updateReportStatus(UpdateInformationReportStatusRequest req) {
    auto report = repo.findById(req.tenantId, req.reportId);
    if (report.isNull)
      return CommandResult(false, "", "Information report not found");

    report.status = req.status.toInformationReportStatus;
    if (req.downloadUrl.length > 0) report.downloadUrl = req.downloadUrl;
    if (req.totalRecords > 0) report.totalRecords = req.totalRecords;
    if (report.status == InformationReportStatus.completed) {
      report.generatedAt = currentTimestamp();
      report.expiresAt = report.generatedAt + 7 * 24 * 60 * 60 * 10_000_000L; // 7 days
    }

    repo.update(report);
    return CommandResult(true, report.id.value, "");
  }

  CommandResult deleteReport(TenantId tenantId, InformationReportId reportId) {
    auto report = repo.findById(tenantId, reportId);
    if (report.isNull)
      return CommandResult(false, "", "Information report not found");

    repo.remove(report);
    return CommandResult(true, report.id.value, "");
  }

}
