import 'package:excel/excel.dart';
import 'dart:io';

class ExcelService {
  Future<List<Map<String, String>>> parseExcelFile(File file) async {
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    List<Map<String, String>> data = [];

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        if (row.isNotEmpty) {
          Map<String, String> rowData = {};
          rowData['country'] = row[0]?.value.toString() ?? '';
          rowData['state'] = row[1]?.value.toString() ?? '';
          rowData['district'] = row[2]?.value.toString() ?? '';
          rowData['city'] = row[3]?.value.toString() ?? '';
          data.add(rowData);
        }
      }
    }

    return data;
  }
}
