/// Escapes a single CSV field. Quotes fields containing commas, quotes,
/// or newlines, and neutralizes leading characters spreadsheet apps
/// interpret as formulas (=, +, -, @, tab, CR) to prevent CSV/formula
/// injection from free-text fields like comments.
String csvEscape(String value) {
  if (value.isNotEmpty && RegExp(r'^[=+\-@\t\r]').hasMatch(value)) {
    value = "'$value";
  }
  if (value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

/// Parses CSV text into rows of fields, honoring double-quoted fields
/// (including embedded commas, newlines, and "" as an escaped quote).
List<List<String>> parseCsv(String content) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;
  var i = 0;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    rows.add(row);
    row = [];
  }

  while (i < content.length) {
    final char = content[i];
    if (inQuotes) {
      if (char == '"') {
        if (i + 1 < content.length && content[i + 1] == '"') {
          field.write('"');
          i += 2;
          continue;
        }
        inQuotes = false;
        i++;
        continue;
      }
      field.write(char);
      i++;
      continue;
    }

    switch (char) {
      case '"':
        inQuotes = true;
        i++;
        break;
      case ',':
        endField();
        i++;
        break;
      case '\r':
        i++;
        break;
      case '\n':
        endRow();
        i++;
        break;
      default:
        field.write(char);
        i++;
    }
  }

  if (field.isNotEmpty || row.isNotEmpty) {
    endRow();
  }

  return rows.where((r) => r.any((cell) => cell.trim().isNotEmpty)).toList();
}
