import 'dart:async';

import 'package:datapollex/main.dart';
import 'package:datapollex/models/notofication_model.dart';
import 'package:datapollex/notifirer/appstate_notifier.dart';
import 'package:datapollex/screens/auth_screen.dart';
import 'package:datapollex/widgets/notificationcard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Timer? _timer; // Added timer variable to properly manage it

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });

    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadNotifications();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        print('User is null, cannot load notifications');
        return;
      }

      final appState = Provider.of<AppState>(context, listen: false);
      await appState.loadTeacherNotifications(authProvider.user!.id);
    } catch (e) {
      print('Error loading notifications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadNotifications),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (appState.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.separated(
              padding: EdgeInsets.all(16),
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: appState.notifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = appState.notifications[index];
                return NotificationCard(
                  notification: notification,
                  onAccept: () => _acceptBooking(notification),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _acceptBooking(NotificationModel notification) async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final success = await appState.acceptBooking(
        notification.scheduleId,
        notification.id,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Booking accepted successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadNotifications(); // Refresh notifications
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Failed to accept booking. Please try again.'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('Error accepting booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

