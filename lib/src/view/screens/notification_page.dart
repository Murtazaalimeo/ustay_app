import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/src/models/notification_modal.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        centerTitle: true,
        elevation: 0, // No shadow
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline,color: Colors.white),
            onPressed: () {
              _showClearAllDialog(context);
            },
          ),
        ],
      ),
      backgroundColor: Colors.white38, // Dark background for body
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('dateTime', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildNoNotificationsUI();
          }

          List<AppNotification> notifications = snapshot.data!.docs
              .map((doc) =>
              AppNotification.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return _buildNotificationsList(notifications, context);
        },
      ),
    );
  }

  Widget _buildNoNotificationsUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No notifications",
            style: TextStyle(fontSize: 20, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications, BuildContext context) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        AppNotification notification = notifications[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text(
              notification.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(notification.description),
            trailing: !notification.isRead
                ? const Icon(Icons.new_releases, color: Colors.red)
                : null,
            onTap: () async {
              if (!notification.isRead) {
                notification.isRead = true;
                await FirebaseFirestore.instance
                    .collection('notifications')
                    .doc(notification.id)
                    .update({'isRead': true});
              }
            },
          ),
        );
      },
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Clear All Notifications"),
          content: const Text("Are you sure you want to clear all notifications?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Clear All", style: TextStyle(color: Colors.red)),
              onPressed: () {
                _clearAllNotifications();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearAllNotifications() {
    FirebaseFirestore.instance.collection('notifications').get().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}
