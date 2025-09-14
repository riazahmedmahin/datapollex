import 'package:datapollex/main.dart';
import 'package:datapollex/models/scheduleslot_model.dart';
import 'package:datapollex/models/userMode.dart';
import 'package:datapollex/notifirer/appstate_notifier.dart';
import 'package:datapollex/screens/auth_screen.dart';
import 'package:datapollex/widgets/scheduleslotCard.dart';
import 'package:datapollex/widgets/slotCrad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherProfileScreen extends StatefulWidget {
  final UserModel teacher;
  final String selectedLanguage;

  const TeacherProfileScreen({
    Key? key,
    required this.teacher,
    required this.selectedLanguage,
  }) : super(key: key);

  @override
  _TeacherProfileScreenState createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final GlobalKey<FormState> _paymentFormKey = GlobalKey<FormState>();
  String _cardHolderName = '';
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  ScheduleSlot? _currentSlot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      final currentUser =
          Provider.of<AuthProvider>(context, listen: false).user!;
      appState.loadAvailableSlots(
        widget.teacher.id,
        widget.selectedLanguage,
        currentUser.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teacher.name),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Teacher Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.teacher.name.isNotEmpty
                          ? widget.teacher.name[0].toUpperCase()
                          : 'T',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.teacher.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// About Section
                  if (widget.teacher.bio.isNotEmpty) ...[
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.teacher.bio,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  /// Languages Section
                  Text(
                    'Languages',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.teacher.languages.map((language) {
                      final isSelected = language == widget.selectedLanguage;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade600
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          language,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  /// Available Slots Section
                  Consumer<AppState>(
                    builder: (context, appState, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Available Slots',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (appState.availableSlots.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${appState.availableSlots.length} available',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (appState.isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (appState.availableSlots.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.schedule_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No available slots',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Check back later for new availability',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: appState.availableSlots.map((slot) {
                                return SlotCard(
                                  slot: slot,
                                  onBook: () => _showPaymentDialog(context, slot),
                                );
                              }).toList(),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, ScheduleSlot slot) {
    _currentSlot = slot;
    _cardHolderName = '';
    _cardNumber = '';
    _expiryDate = '';
    _cvv = '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.credit_card,
                      size: 32,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Title
                  Text(
                    'Payment Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Lesson info
                  Text(
                    '${slot.language} Lesson - \$${slot.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  
                  Form(
                    key: _paymentFormKey,
                    child: Column(
                      children: [
                        // Card Holder Name
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Card Holder Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.person_outline),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) => value?.isEmpty ?? true 
                              ? 'Please enter card holder name' 
                              : null,
                          onChanged: (value) => _cardHolderName = value,
                        ),
                        SizedBox(height: 16),
                        
                        // Card Number
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Card Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.credit_card),
                            hintText: 'XXXX XXXX XXXX XXXX',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value?.isEmpty ?? true || value!.length < 16
                              ? 'Please enter valid card number' 
                              : null,
                          onChanged: (value) => _cardNumber = value,
                        ),
                        SizedBox(height: 16),
                        
                        // Expiry Date and CVV
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Expiry Date',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: Icon(Icons.calendar_today),
                                  hintText: 'MM/YY',
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                validator: (value) => value?.isEmpty ?? true 
                                    ? 'Please enter expiry date' 
                                    : null,
                                onChanged: (value) => _expiryDate = value,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'CVV',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: Icon(Icons.lock_outline),
                                  hintText: 'XXX',
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                validator: (value) => value?.isEmpty ?? true || value!.length < 3
                                    ? 'Please enter valid CVV' 
                                    : null,
                                onChanged: (value) => _cvv = value,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Secure payment info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Secure payment encrypted',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_paymentFormKey.currentState!.validate()) {
                              Navigator.pop(dialogContext); // Close payment dialog
                              // Use a small delay to ensure the dialog is fully closed
                              await Future.delayed(Duration(milliseconds: 100));
                              _bookSlot(dialogContext, _currentSlot!);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Pay & Book Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _bookSlot(BuildContext dialogContext, ScheduleSlot slot) async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user!;
    final appState = Provider.of<AppState>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text(
          'Book this ${slot.language} lesson for ${_formatDateTime(slot.dateTime)}?\n\nPrice: \$${slot.price.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
            ),
            child: const Text(
              'Confirm Booking',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await appState.bookSlot(
        slot.id,
        currentUser.id,
        currentUser.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Lesson booked successfully! Waiting for teacher confirmation.'
                  : 'Failed to book lesson. Please try again.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
