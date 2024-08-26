import 'package:cab/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('images/chalo.mp4')
      ..initialize().then((_) {
        setState(() {}); // Update the UI after initialization
        _controller.play();
      });

    _controller.setLooping(false);
    // Set to true if you want the video to loop
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        // Video has ended
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(), // Replace with your main screen
          ),
        );
      }
    });
  }

  @override


  @override
  Widget build(BuildContext context) {
    double videoWidth =1080;
    double videoHeight=1920;
    return Scaffold(
     body: Center(
       child: _controller.value.isInitialized ? SizedBox(
         width: videoWidth,
         height: videoHeight,
         child: FittedBox(
           fit: BoxFit.cover,
           child: SizedBox(
             width: _controller.value.size.width,
             height: _controller.value.size.height,
             child: VideoPlayer(_controller),
         ),
       ),
     ): const CircularProgressIndicator(),
     ),
    );
  }
}
