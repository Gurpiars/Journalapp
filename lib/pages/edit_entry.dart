import 'package:flutter/material.dart';
import 'package:untitled/classes/database.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class EditEntry extends StatefulWidget {
  final bool add;
  final int index;
  final JournalEdit journalEdit;

  const EditEntry({
    Key? key,
    required this.add,
    required this.journalEdit,
    required this.index,
  }) : super(key: key);

  @override
  State<EditEntry> createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  late JournalEdit _journalEdit;
  late String _title;
  late DateTime _selectedDate;
  TextEditingController _moodController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  FocusNode _moodFocus = FocusNode();
  FocusNode _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _journalEdit = JournalEdit(
      action: 'Cancel',
      journal: widget.journalEdit.journal,
    );
    _title = widget.add ? 'Add' : 'Edit';
    if (widget.add) {
      _selectedDate = DateTime.now();
      _moodController.text = '';
      _noteController.text = '';
    } else {
      _selectedDate = DateTime.parse(_journalEdit.journal.date);
      _moodController.text = _journalEdit.journal.mood;
      _noteController.text = _journalEdit.journal.note;
    }
  }

  @override
  void dispose() {
    _moodController.dispose();
    _noteController.dispose();
    _moodFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  Future<DateTime> _selectDate(DateTime selectedDate) async {
    DateTime _initialdate = selectedDate;

    final DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: _initialdate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (_pickedDate != null) {
      selectedDate = DateTime(
        _pickedDate.year,
        _pickedDate.month,
        _pickedDate.day,
        _pickedDate.hour,
      );
    }
    return selectedDate;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_title Entry'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              TextButton(
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime _pickerDate = await _selectDate(_selectedDate);
                  setState(() {
                    _selectedDate = _pickerDate;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20.0,
                      color: Colors.black,
                    ),
                    SizedBox(width: 15.0),
                    Text(
                      DateFormat.yMMMEd().format(_selectedDate),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              TextField(
                controller: _moodController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                focusNode: _moodFocus,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Mood',
                  icon: Icon(Icons.mood),
                ),
                onSubmitted: (submitted) {
                  FocusScope.of(context).requestFocus(_noteFocus);
                },
              ),
              TextField(
                controller: _noteController,
                textInputAction: TextInputAction.newline,
                focusNode: _noteFocus,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Note',
                  icon: Icon(Icons.subject),
                ),
                maxLines: null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    color: Colors.blueGrey,
                    child: ElevatedButton(
                      onPressed: () {
                        _journalEdit.action = 'Cancel';
                        Navigator.pop(context, _journalEdit);
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Container(
                    color: Colors.blueGrey,
                    child: ElevatedButton(
                      onPressed: () {
                        print('svae');
                        setState(() {
                          _journalEdit.action = 'Save';
                          String _id = widget.add
                              ? Random().nextInt(999999).toString()
                              : _journalEdit.journal.id;
                          _journalEdit.journal = Journal(
                            id: _id,
                            date: _selectedDate.toString(),
                            mood: _moodController.text,
                            note: _noteController.text,
                          );
                        });
                        Navigator.pop(context, _journalEdit);
                      },
                      child: Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
