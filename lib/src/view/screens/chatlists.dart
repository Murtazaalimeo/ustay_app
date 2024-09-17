import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/src/view/screens/userchatroom.dart';
import 'package:intl/intl.dart'; // for formatting timestamps

class ChatListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats',style: TextStyle(color: Colors.white, fontSize: 13),),
        backgroundColor: Colors.deepPurple,

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('chatroom')
            .where('participants', arrayContains: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final chatRooms = snapshot.data!.docs;
            if (chatRooms.isEmpty) {
              return const Center(child: Text('No chats yet.'));
            }

            return ListView.separated(
              itemCount: chatRooms.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[300],
              ),
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];
                final participants = chatRoom['participants'];
                final otherUserId = participants.firstWhere((id) => id != _auth.currentUser?.uid);

                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('users').doc(otherUserId).get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: const Text('Loading...'),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[200],
                        ),
                      );
                    }

                    if (userSnapshot.hasError) {
                      return const ListTile(
                        title: Text('Error loading user data'),
                      );
                    }

                    if (userSnapshot.hasData && userSnapshot.data!.exists) {
                      final userData = userSnapshot.data!.data() as Map<String, dynamic>;

                      // Extracting user information
                      String profileImageUrl = userData['profileImageUrl'] ?? '';
                      String firstName = userData['name'] ?? 'Unknown';

                      // Getting the last message
                      String lastMessage = chatRoom['lastMessage'] ?? '';

                      // Formatting the last message time
                      String lastMessageTime = _formatTimestamp(chatRoom['lastMessageTime']);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : const AssetImage('assets/images/avatar.png') as ImageProvider,
                          radius: 25,
                        ),
                        title: Text(
                          firstName.isNotEmpty ? firstName : 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lastMessageTime,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            // Optionally, show unread message count
                            // CircleAvatar(
                            //   radius: 10,
                            //   backgroundColor: Colors.red,
                            //   child: Text(
                            //     '3',  // Example unread count
                            //     style: TextStyle(color: Colors.white, fontSize: 12),
                            //   ),
                            // ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoom(
                                chatRoomId: chatRoom.id,
                                userMap: userData,
                                user: userSnapshot.data!,
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const ListTile(
                        title: Text('User data not available'),
                      );
                    }
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading chats: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final DateTime date = timestamp.toDate();
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return DateFormat('h:mm a').format(date); // Same day
    } else if (now.difference(date).inDays == 1) {
      return 'Yesterday'; // Previous day
    } else {
      return DateFormat('MM/dd/yyyy').format(date); // Other dates
    }
  }
}
