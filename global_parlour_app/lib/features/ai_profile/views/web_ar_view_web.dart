import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;

class WebARTryOnView extends StatefulWidget {
  final String selectedFilterId;
  const WebARTryOnView({super.key, required this.selectedFilterId});

  @override
  State<WebARTryOnView> createState() => _WebARTryOnViewState();
}

class _WebARTryOnViewState extends State<WebARTryOnView> {
  final String viewId = 'face-api-production-view';
  bool _scriptInjected = false;

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final div = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.position = 'relative'
        ..style.backgroundColor = 'black';

      final video = html.VideoElement()
        ..id = 'webcam-video'
        ..autoplay = true
        ..muted = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      final canvas = html.CanvasElement()
        ..id = 'overlay-canvas'
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.left = '0'
        ..style.width = '100%'
        ..style.height = '100%';

      div.append(video);
      div.append(canvas);

      if (!_scriptInjected) {
        _injectScripts();
        _scriptInjected = true;
      }

      return div;
    });
  }

  @override
  void didUpdateWidget(WebARTryOnView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFilterId != widget.selectedFilterId) {
      _updateJSFilter();
    }
  }

  void _updateJSFilter() {
    html.window.postMessage({'type': 'UPDATE_FILTER', 'filterId': widget.selectedFilterId}, '*');
  }

  void _injectScripts() {
    final script = html.ScriptElement()
      ..src = 'https://cdn.jsdelivr.net/npm/@vladmandic/face-api/dist/face-api.js'
      ..type = 'text/javascript';

    script.onLoad.listen((e) {
      final initScript = html.ScriptElement()
        ..text = '''
        let currentFilterId = '${widget.selectedFilterId}';
        
        window.addEventListener('message', (event) => {
          if (event.data.type === 'UPDATE_FILTER') {
            currentFilterId = event.data.filterId;
          }
        });

        async function initFaceAPI() {
          const video = document.getElementById('webcam-video');
          const canvas = document.getElementById('overlay-canvas');
          
          await faceapi.nets.tinyFaceDetector.loadFromUri('https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model/');
          await faceapi.nets.faceLandmark68Net.loadFromUri('https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model/');
          
          navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user' } })
            .then(stream => {
              video.srcObject = stream;
            }).catch(err => console.error('Camera failed:', err));

          video.addEventListener('play', () => {
             const displaySize = { width: video.clientWidth, height: video.clientHeight };
             faceapi.matchDimensions(canvas, displaySize);
             
             setInterval(async () => {
                const detections = await faceapi.detectAllFaces(video, new faceapi.TinyFaceDetectorOptions()).withFaceLandmarks();
                const resizedDetections = faceapi.resizeResults(detections, displaySize);
                
                const ctx = canvas.getContext('2d');
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                
                if (resizedDetections.length > 0) {
                   const landmarks = resizedDetections[0].landmarks;
                   const points = landmarks.getPositions();
                   
                   // LIPS (48-67)
                   if (['classic_red', 'nude_glow', 'pink_blush'].includes(currentFilterId)) {
                      let color = 'rgba(255, 0, 0, 0.4)'; // red
                      if (currentFilterId === 'nude_glow') color = 'rgba(212, 165, 165, 0.5)';
                      if (currentFilterId === 'pink_blush') color = 'rgba(255, 105, 180, 0.5)';
                      
                      const lips = points.slice(48, 60);
                      ctx.fillStyle = color;
                      ctx.beginPath();
                      ctx.moveTo(lips[0].x, lips[0].y);
                      for (let i=1; i<lips.length; i++) ctx.lineTo(lips[i].x, lips[i].y);
                      ctx.closePath();
                      ctx.fill();
                   }

                   // EYELINER / EYES (36-47)
                   if (['winged_eyes', 'classic_red'].includes(currentFilterId)) {
                      ctx.strokeStyle = 'rgba(0, 0, 0, 0.7)';
                      ctx.lineWidth = 2.5;
                      const leftEye = points.slice(36, 42);
                      const rightEye = points.slice(42, 48);
                      
                      const drawEye = (pts) => {
                         ctx.beginPath();
                         ctx.moveTo(pts[0].x, pts[0].y);
                         for (let i=1; i<pts.length; i++) ctx.lineTo(pts[i].x, pts[i].y);
                         ctx.closePath();
                         ctx.stroke();
                      };
                      drawEye(leftEye);
                      drawEye(rightEye);
                   }

                   // HAIR COLOR (Pseudo-Simulation via Forehead Region)
                   if (currentFilterId.includes('hair')) {
                      let hairColor = 'rgba(250, 240, 190, 0.3)'; // blonde
                      if (currentFilterId === 'brunette_hair') hairColor = 'rgba(59, 47, 47, 0.4)';
                      if (currentFilterId === 'curly_hair') hairColor = 'rgba(75, 54, 33, 0.4)';

                      const foreheadCenter = points[27];
                      const faceWidth = points[16].x - points[0].x;
                      
                      const gradient = ctx.createRadialGradient(foreheadCenter.x, foreheadCenter.y - faceWidth * 0.4, 10, foreheadCenter.x, foreheadCenter.y - faceWidth * 0.4, faceWidth * 0.8);
                      gradient.addColorStop(0, hairColor);
                      gradient.addColorStop(1, 'rgba(0,0,0,0)');
                      
                      ctx.fillStyle = gradient;
                      ctx.fillRect(foreheadCenter.x - faceWidth, foreheadCenter.y - faceWidth, faceWidth * 2, faceWidth * 1.2);
                   }
                   
                   // ACCESSORIES (SHADES)
                   if (currentFilterId === 'shades') {
                      const leftEyeCenter = points[36];
                      const rightEyeCenter = points[45];
                      const eyeDist = rightEyeCenter.x - leftEyeCenter.x;
                      
                      ctx.fillStyle = 'rgba(20, 20, 20, 0.9)';
                      // Left lens
                      ctx.beginPath();
                      ctx.ellipse(leftEyeCenter.x, leftEyeCenter.y, eyeDist * 0.6, eyeDist * 0.4, 0, 0, 2 * Math.PI);
                      ctx.fill();
                      // Right lens
                      ctx.beginPath();
                      ctx.ellipse(rightEyeCenter.x, rightEyeCenter.y, eyeDist * 0.6, eyeDist * 0.4, 0, 0, 2 * Math.PI);
                      ctx.fill();
                      // Bridge
                      ctx.strokeStyle = 'black';
                      ctx.lineWidth = 4;
                      ctx.beginPath();
                      ctx.moveTo(leftEyeCenter.x + eyeDist * 0.3, leftEyeCenter.y);
                      ctx.lineTo(rightEyeCenter.x - eyeDist * 0.3, rightEyeCenter.y);
                      ctx.stroke();
                   }
                }
             }, 80);
          });
        }
        initFaceAPI();
        ''';
      html.document.body!.append(initScript);
    });

    html.document.head!.append(script);
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: viewId);
  }
}
