module uim.platform.databricks.domain.entities.notebook;
import uim.platform.databricks;

// mixin(ShowModule!());

@safe:

/// A Databricks notebook — executable document with code and markdown cells.
struct Notebook {
  mixin TenantEntity!(NotebookId);

  WorkspaceId      workspaceId;
  string           path;
  string           name;
  NotebookLanguage language;
  NotebookStatus   status;
  string           content;         // Base64-encoded or plain source
  string           format;          // SOURCE, HTML, JUPYTER, DBC
  string           ownerId;
  long             createdAt;
  long             modifiedAt;
}
