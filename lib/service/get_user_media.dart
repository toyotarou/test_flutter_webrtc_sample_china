import 'package:flutter/material.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'dart:core';

class GetUserMedia extends StatefulWidget {
  const GetUserMedia({super.key});

  @override
  State<GetUserMedia> createState() => _GetUserMediaState();
}

class _GetUserMediaState extends State<GetUserMedia> {
  late MediaStream localStream;

  final localRenderer = RTCVideoRenderer();

  bool isOpen = false;

  ///
  @override
  void initState() {
    super.initState();

    initRenderers();
  }

  ///
  initRenderers() async {
    try {
      await localRenderer.initialize();
    } catch (e) {
      print('RTCVideoRenderer initialization failed: $e');
    }
  }

  ///
  open() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {'width': 1280, 'height': 720}
    };

    try {
      // navigator.mediaDevices.getUserMediaを使用
      final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      setState(() {
        localStream = stream;
        localRenderer.srcObject = localStream;
        isOpen = true;
      });
    } catch (e) {
      print('Error opening media stream: $e');
    }
  }

  ///
  close() async {
    try {
      // MediaStream内のすべてのトラックを停止
      localStream.getTracks().forEach((track) => track.stop());

      setState(() {
        // リソース解放
        localStream.dispose();
        localRenderer.srcObject = null;
        isOpen = false;
      });
    } catch (e) {
      print('Error closing media stream: $e');
    }
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GetUserMedia')),
      body: OrientationBuilder(builder: (context, orientation) {
        return Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                RTCVideoView(localRenderer),
                if (!isOpen) const Center(child: Text('No video stream')),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: (isOpen) ? close : open,
        child: Icon((isOpen) ? Icons.close : Icons.add),
      ),
    );
  }
}
