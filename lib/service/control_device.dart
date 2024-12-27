import 'package:flutter/material.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'dart:core';

class ControlDevice extends StatefulWidget {
  const ControlDevice({super.key});

  @override
  State<ControlDevice> createState() => _ControlDeviceState();
}

class _ControlDeviceState extends State<ControlDevice> {
  late MediaStream localStream;

  final localRenderer = RTCVideoRenderer();

  bool isOpen = false;

  bool cameraOff = false;
  bool micOff = false;
  bool speakerOn = true;

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
      appBar: AppBar(title: Text('GetUserMedia')),
      body: OrientationBuilder(builder: (context, orientation) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                RTCVideoView(localRenderer),
                if (!isOpen) Center(child: Text('No video stream')),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: (isOpen) ? close : open,
        child: Icon((isOpen) ? Icons.close : Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                onPressed: () {
                  turnCamera();
                },
                icon: Icon(cameraOff ? Icons.videocam_off : Icons.videocam)),
            IconButton(
                onPressed: () {
                  switchCamera();
                },
                icon: Icon(Icons.switch_camera)),
            IconButton(
                onPressed: () {
                  turnMic();
                },
                icon: Icon(micOff ? Icons.mic_off : Icons.mic)),
            IconButton(onPressed: () {}, icon: Icon(speakerOn ? Icons.volume_up : Icons.volume_down)),
          ],
        ),
      ),
    );
  }

  ///
  switchCamera() {
    if (localStream.getVideoTracks().isNotEmpty) {
      // Helper.switchCamera() を使用
      Helper.switchCamera(localStream.getVideoTracks()[0]);
    } else {
      print('No video tracks available for switching camera');
    }
  }

  ///
  turnCamera() {
    if (localStream.getVideoTracks().isNotEmpty) {
      var muted = !cameraOff;

      setState(() {
        cameraOff = muted;
      });

      localStream.getVideoTracks()[0].enabled = !muted;
    } else {}
  }

  ///
  turnMic() {
    if (localStream.getVideoTracks().isNotEmpty) {
      var muted = !micOff;

      setState(() {
        micOff = muted;
      });

      localStream.getAudioTracks()[0].enabled = !muted;

      if (muted) {
        print('micOff');
      } else {
        print('micOn');
      }
    } else {}
  }
}
