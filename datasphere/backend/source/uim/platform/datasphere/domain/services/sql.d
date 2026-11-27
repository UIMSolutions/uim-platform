/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Checks of the SQL of views: a single read-only SELECT (or WITH … SELECT)
/// statement; the objects after FROM / JOIN are the sources of the view
/// and must exist in the space.
module uim.platform.datasphere.domain.services.sql;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

/// Statements that change data or catalog objects — never part of a view.
enum string[] forbiddenSqlKeywords = [
    "INSERT", "UPDATE", "DELETE", "MERGE", "UPSERT", "REPLACE", "DROP", "ALTER", "CREATE", "TRUNCATE", "GRANT", "REVOKE",
    "CALL", "EXEC", "EXECUTE", "COMMIT", "ROLLBACK"
  ];

/// Words of the statement outside string literals and comments, upper case;
/// quoted identifiers ("Name") keep their case and lose the quotes.
string[] sqlTokens(string sql) {
  string[] tokens;
  string current;
  void flush() {
    if (current.length)
      tokens ~= current;
    current = "";
  }

  size_t i;
  while (i < sql.length) {
    auto c = sql[i];
    if (c == '\'') { // string literal ('' escapes)
      flush();
      i++;
      while (i < sql.length) {
        if (sql[i] == '\'') {
          if (i + 1 < sql.length && sql[i + 1] == '\'') {
            i += 2;
            continue;
          }
          break;
        }
        i++;
      }
      if (i >= sql.length)
        throw DspException.invalid("SQL: unterminated string literal");
      i++;
      tokens ~= "'";
      continue;
    }
    if (c == '"') { // quoted identifier
      flush();
      auto end = sql.indexOf('"', i + 1);
      if (end < 0)
        throw DspException.invalid("SQL: unterminated quoted identifier");
      tokens ~= sql[i + 1 .. end];
      i = end + 1;
      continue;
    }
    if (c == '-' && i + 1 < sql.length && sql[i + 1] == '-') { // line comment
      flush();
      while (i < sql.length && sql[i] != '\n')
        i++;
      continue;
    }
    if (c == '/' && i + 1 < sql.length && sql[i + 1] == '*') { // block comment
      flush();
      auto end = sql.indexOf("*/", i + 2);
      i = end < 0 ? sql.length : end + 2;
      continue;
    }
    auto word = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == '.' || c == '$';
    if (word)
      current ~= c >= 'a' && c <= 'z' ? cast(char)(c - 32) : c;
    else {
      flush();
      if (c == ';' || c == '(' || c == ')' || c == ',')
        tokens ~= [c].idup;
    }
    i++;
  }
  flush();
  return tokens;
}

/// Validate the SQL of a view; returns the referenced objects (FROM / JOIN),
/// without duplicates, in order of appearance. Names keep the case of the
/// statement for quoted identifiers; unquoted names are upper case.
string[] analyzeViewSql(string sql) {
  requireText(sql, "SQL expression");
  requireMaxLength(sql, 100_000, "SQL expression");
  auto tokens = sqlTokens(sql);
  while (tokens.length && tokens[$ - 1] == ";")
    tokens = tokens[0 .. $ - 1];
  if (tokens.length == 0 || (tokens[0] != "SELECT" && tokens[0] != "WITH"))
    throw DspException.invalid("The SQL of a view must be a SELECT statement");
  if (tokens.canFind(";"))
    throw DspException.invalid("The SQL of a view must be a single statement");
  foreach (t; tokens)
    if (forbiddenSqlKeywords.canFind(t))
      throw DspException.invalid("The SQL of a view must not contain " ~ t);
  if (!tokens.canFind("FROM"))
    throw DspException.invalid("The SQL of a view must read FROM at least one object");

  string[] sources;
  string[] ctes; /// names defined by WITH
  foreach (i, t; tokens) {
    if (t == "AS" && i > 0 && i + 1 < tokens.length && tokens[i + 1] == "(" && tokens[0] == "WITH")
      ctes ~= tokens[i - 1];
    if ((t == "FROM" || t == "JOIN") && i + 1 < tokens.length) {
      auto name = tokens[i + 1];
      if (name == "(" || name == "'" || ctes.canFind(name) || name == "DUMMY")
        continue;
      if (!sources.canFind(name))
        sources ~= name;
    }
  }
  return sources;
}

///
unittest {
  auto s = analyzeViewSql(`SELECT o.SALESORDER, c."Name" FROM S4_SALES_ORDERS o
    LEFT JOIN "Customers" c ON c.ID = o.SOLDTO -- comment FROM X
    WHERE o.COUNTRY = 'DE; DROP' /* JOIN Y */;`);
  assert(s == ["S4_SALES_ORDERS", "Customers"], s.to!string);
  assert(analyzeViewSql("select * from a.b join a.b on 1=1") == ["A.B"]);
  assert(analyzeViewSql("WITH x AS (SELECT * FROM T1) SELECT * FROM x") == ["T1"]);
  assert(analyzeViewSql("SELECT * FROM (SELECT * FROM T2) q") == ["T2"]);
  assert(failsWith(DspErrorKind.invalid, () { analyzeViewSql("DELETE FROM T"); }));
  assert(failsWith(DspErrorKind.invalid, () { analyzeViewSql("SELECT * FROM T; DROP TABLE T"); }));
  assert(failsWith(DspErrorKind.invalid, () { analyzeViewSql("SELECT 1"); }));
  assert(failsWith(DspErrorKind.invalid, () { analyzeViewSql("SELECT * FROM T WHERE x IN (SELECT y FROM U) OR UPDATE"); }));
}
