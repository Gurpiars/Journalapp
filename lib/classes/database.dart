import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class DatabaseFileRoutines {
  //Documents directory path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //Path combined with the filename
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_persistence.json');
  }

  // To read journals and catch errors
  Future<String> readJournals() async {
    try {
      final file = await _localFile;
      //To check weather file exists if not create it
      if (!file.existsSync()) {
        print("File does not Exist: ${file.absolute}");
        await writeJournals('{"journals":[]}');
      }
      //To load the content of files
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      print('error readJournals: $e');
      return "";
    }
  }

  //To save the journal Json to file
  Future<File> writeJournals(String json) async {
    final file = await _localFile;
    return file.writeAsString('$json');
  }
}

// Json decode & encode for entire database
Database databaseFromJson(String str) {
  final datafromJson = json.decode(str);
  return Database.fromJson(datafromJson);
}

//Parsing Values to Json string
String databaseToJson(Database data) {
  final dataToJson = data.toJson();
  return jsonEncode(dataToJson);
}

class Database {
  List<Journal> journal;
  Database({
    required this.journal,
  });

  //To retrieve and map the Json objects to List<Journal>
  factory Database.fromJson(Map<String, dynamic> json) => Database(
        journal: List<Journal>.from(
            json["journals"].map((x) => Journal.fromJson(x))),
      );

  //To convert the List<Journal> to Json objects
  Map<String, dynamic> toJson() => {
        "journals": List<dynamic>.from(journal.map((x) => x.toJson())),
      };
}

class Journal {
  String id;
  String date;
  String mood;
  String note;

  Journal({
    required this.id,
    required this.date,
    required this.mood,
    required this.note,
  });
  factory Journal.fromJson(Map<String, dynamic> json) => Journal(
        id: json["id"],
        date: json["date"],
        mood: json["mood"],
        note: json["note"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "mood": mood,
        "note": note,
      };
}

class JournalEdit {
  String action;
  Journal journal;

  JournalEdit({required this.journal, required this.action});
}
