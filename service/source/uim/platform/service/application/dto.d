module uim.platform.service.application.dto;

@safe:
struct CommandResult {
  string id;
  string error;

  bool isSuccess() const
  {
    return error.length == 0;
  }
}