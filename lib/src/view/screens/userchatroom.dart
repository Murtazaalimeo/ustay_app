import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;


  ChatRoom({super.key, required this.chatRoomId, required this.userMap, required user});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _imageFile;
  bool _isUploadingImage = false;


  Future<void> _getImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isUploadingImage = true;
        });
        await _uploadImage();
      }
    } catch (e) {
      _showErrorDialog("Image Pick Error", "Failed to pick image: $e");
    }
  }

  Future<void> _uploadImage() async {
    try {
      final fileName = const Uuid().v1();
      final ref = FirebaseStorage.instance.ref().child('images/$fileName.jpg');

      await ref.putFile(_imageFile!);

      final imageUrl = await ref.getDownloadURL();
      await _firestore.collection('chatroom').doc(widget.chatRoomId).collection('chats').doc(fileName).set({
        "sendby": _auth.currentUser?.displayName ?? "Unknown",
        "message": imageUrl,
        "type": "img",
        "time": FieldValue.serverTimestamp(),
      });

      setState(() {

        _isUploadingImage = false;

      });
    } catch (e) {
      _showErrorDialog("Image Upload Error", "Failed to upload image: $e");
    }
  }

  Future<void> _onSendMessage() async {
    if (_messageController.text.isEmpty) {
      return _showErrorDialog("Empty Message", "Please enter a message before sending.");
    }

    try {
      final message = {
        "sendby": _auth.currentUser?.displayName ?? "Unknown",
        "message": _messageController.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _messageController.clear();
      await _firestore.collection('chatroom').doc(widget.chatRoomId).collection('chats').add(message);
    } catch (e) {
      _showErrorDialog("Message Send Error", "Failed to send message: $e");
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection("users").doc(widget.userMap['email']).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.userMap['name'] ?? '', style: const TextStyle(fontSize: 18, color: Colors.white)),
                  Text(
                    snapshot.data?['status'] ?? 'Offline',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('chatroom').doc(widget.chatRoomId).collection('chats').orderBy("time", descending: false).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      });
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final map = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                          return _messageItem(size, map, context);
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Failed to load messages: ${snapshot.error}"));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: Colors.white.withOpacity(0.8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Send a message...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo),
                      onPressed: _getImage,
                      color: Colors.deepPurple,
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _onSendMessage,
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isUploadingImage)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _messageItem(Size size, Map<String, dynamic> map, BuildContext context) {
    final formattedTime = map['time'] != null ? DateFormat('h:mm a').format(map['time'].toDate()) : "";
    final isCurrentUser = map['sendby'] == _auth.currentUser?.displayName;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 5),
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isCurrentUser ? Colors.deepPurple : Colors.white38,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: map['type'] == "text"
                ? Text(
              map['message'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isCurrentUser ? Colors.white : Colors.black,
              ),
            )
                : InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(imageUrl: map['message']),
                ),
              ),
              child: Image.network(
                map['message'],
                height: size.height / 2.5,
                width: size.width / 2,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl, fit: BoxFit.contain),
      ),
    );
  }
}
