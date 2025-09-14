import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datapollex/main.dart';
import 'package:datapollex/models/scheduleslot_model.dart';
import 'package:datapollex/screens/auth_screen.dart';
import 'package:datapollex/widgets/scheduleslotCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleManagementScreen extends StatefulWidget {
  @override
  _ScheduleManagementScreenState createState() =>
      _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedLanguage = '';
  int _duration = 60;
  double _price = 25.0;
  List<ScheduleSlot> _mySlots = [];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    if (user.languages.isNotEmpty) {
      _selectedLanguage = user.languages.first;
    }
    _loadMySlots();
  }

  Future<void> _loadMySlots() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('schedules')
              .where('teacherId', isEqualTo: user.id)
              .orderBy('dateTime')
              .get();

      setState(() {
        _mySlots =
            querySnapshot.docs
                .map((doc) => ScheduleSlot.fromMap(doc.data()))
                .toList();
      });
    } catch (e) {
      print('Error loading slots: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Schedule'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add New Slot Form
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Time Slot',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Language Selection
                      DropdownButtonFormField<String>(
                        value:
                            _selectedLanguage.isEmpty
                                ? null
                                : _selectedLanguage,
                        decoration: InputDecoration(
                          labelText: 'Language',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items:
                            user.languages
                                .map(
                                  (lang) => DropdownMenuItem(
                                    value: lang,
                                    child: Text(lang),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) =>
                                setState(() => _selectedLanguage = value!),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Please select a language'
                                    : null,
                      ),
                      SizedBox(height: 16),

                      // Date Selection
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Time Selection
                      InkWell(
                        onTap: _selectTime,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Time',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Duration Selection
                      DropdownButtonFormField<int>(
                        value: _duration,
                        decoration: InputDecoration(
                          labelText: 'Duration (minutes)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items:
                            [30, 45, 60, 90, 120]
                                .map(
                                  (duration) => DropdownMenuItem(
                                    value: duration,
                                    child: Text('$duration minutes'),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() => _duration = value!),
                      ),
                      SizedBox(height: 16),

                      // Price Input
                      TextFormField(
                        initialValue: _price.toString(),
                        decoration: InputDecoration(
                          labelText: 'Price (\$)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged:
                            (value) =>
                                _price = double.tryParse(value) ?? _price,
                        validator:
                            (value) =>
                                double.tryParse(value ?? '') == null
                                    ? 'Please enter a valid price'
                                    : null,
                      ),
                      SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addSlot,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Add Time Slot',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // My Slots List
            
            SizedBox(height: 16),

            if (_mySlots.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      '',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              )
            else
              ..._mySlots.map(
                (slot) => Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          slot.isBooked
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                      child: Icon(
                        slot.isBooked
                            ? Icons.event_busy
                            : Icons.event_available,
                        color: slot.isBooked ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(
                      '${slot.language} - ${slot.dateTime.day}/${slot.dateTime.month}/${slot.dateTime.year}',
                    ),
                    subtitle: Text(
                      '${slot.dateTime.hour}:${slot.dateTime.minute.toString().padLeft(2, '0')} - ${slot.duration} min - \$${slot.price.toStringAsFixed(2)}',
                    ),
                    trailing:
                        slot.isBooked
                            ? Chip(
                              label: Text('Booked'),
                              backgroundColor: Colors.red.shade100,
                            )
                            : IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSlot(slot.id),
                            ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _addSlot() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final slot = ScheduleSlot(
      id: '',
      teacherId: user.id,
      teacherName: user.name,
      dateTime: dateTime,
      duration: _duration,
      language: _selectedLanguage,
      price: _price,
      status: 'available',
    );

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('schedules')
          .add(slot.toMap());
      await docRef.update({'id': docRef.id});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Time slot added successfully!')));

      _loadMySlots();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding slot: $e')));
    }
  }

  Future<void> _deleteSlot(String slotId) async {
    try {
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(slotId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Slot deleted successfully!')));
      _loadMySlots();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting slot: $e')));
    }
  }
}
