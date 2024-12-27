import 'package:flutter/material.dart';
import 'package:test_flutter_webrtc_china/service/control_device.dart';
import 'package:test_flutter_webrtc_china/service/get_user_media.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC sample'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('GetUserMedia Sample'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const GetUserMedia()));
            },
          ),
          ListTile(
            title: const Text('Control Device Sample'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ControlDevice()));
            },
          )
        ],
      ),
    );
  }
}
