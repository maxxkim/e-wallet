import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:zippy/internal/services/logger_service.dart';

class EdgeTierChatWidget extends StatefulWidget {
  // Properties for initializing the chat
  final String setupId;
  final String companyIdentifier;
  final bool usePreProd;
  final bool showControls;
  final double? height;
  final double? width;
  final Function(bool isAvailable)? onAvailabilityChanged;
  final VoidCallback? onChatOpened;

  const EdgeTierChatWidget({
    Key? key,
    required this.setupId,
    this.companyIdentifier = "ZENTRO",
    this.usePreProd = false,
    this.showControls = false,
    this.height,
    this.width,
    this.onAvailabilityChanged,
    this.onChatOpened,
  }) : super(key: key);

  @override
  EdgeTierChatWidgetState createState() => EdgeTierChatWidgetState();
}

class EdgeTierChatWidgetState extends State<EdgeTierChatWidget> {
  late WebViewController _controller;
  bool isEdgeTierLoaded = false;
  final LoggerService _logger = LoggerService();

  @override
  void initState() {
    super.initState();
    _logger.info('✨ EdgeTierChatWidget initializing UwU ✨');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _logger.info('📱 WebView page loaded, checking EdgeTier status~');
            _checkEdgeTierLoaded();
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _logger.info('📨 Received message from JS: ${message.message} nyaa~');
          _handleJsMessage(message.message);
        },
      )
      ..loadHtmlString(_generateHtmlWithEdgeTier());
  }

  void _handleJsMessage(String message) {
    if (message.startsWith('availability:')) {
      final isAvailable = message.split(':')[1] == 'true';
      _logger.info('🔍 Chat availability changed: $isAvailable UwU');
      if (widget.onAvailabilityChanged != null) {
        widget.onAvailabilityChanged!(isAvailable);
      }
    } else if (message == 'chatOpened') {
      _logger.info('📲 Chat opened successfully! Kawaii~ ヽ(♡‿♡)ノ');
      if (widget.onChatOpened != null) {
        widget.onChatOpened!();
      }
    } else if (message.startsWith('edgeTierLoaded:')) {
      _logger.info('✅ EdgeTier library loaded: ${message.split(':')[1]} nyaa~');
    }
  }

  String _generateHtmlWithEdgeTier() {
    final scriptSrc = widget.usePreProd
        ? "https://chat-preprod.edgetier.com/js/edgetier.js"
        : "https://chat.edgetier.com/js/edgetier.js";
    _logger.info('🔗 Using EdgeTier script from: $scriptSrc');
    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <title>EdgeTier Chat</title>
          <script defer src="$scriptSrc" data-id="${widget.setupId}"></script>
          <style>
            body {
              font-family: system-ui, -apple-system, sans-serif;
              margin: 0;
              padding: 0;
              background-color: transparent;
              overflow: hidden;
            }
            .controls {
              display: ${widget.showControls ? 'flex' : 'none'};
              justify-content: center;
              padding: 8px;
              gap: 8px;
            }
            button {
              background-color: #007bff;
              color: white;
              border: none;
              padding: 8px 12px;
              border-radius: 4px;
              font-size: 14px;
              cursor: pointer;
            }
          </style>
        </head>
        <body>
          <div class="controls">
            <button id="checkAvailability">Check Availability</button>
            <button id="showButton">Show Chat Button</button>
            <button id="openChat">Open Chat</button>
          </div>
          
          <script>
            
            function notifyFlutter(message) {
              if (window.FlutterChannel) {
                window.FlutterChannel.postMessage(message);
              }
            }
            
            
            function checkEdgeTierLoaded() {
              if (window.EdgeTierChat) {
                notifyFlutter('edgeTierLoaded:true');
                
                // Check initial availability when loaded
                window.EdgeTierChat.isAvailable((error, data) => {
                  if (!error && data) {
                    notifyFlutter('availability:' + data.isAvailable);
                  }
                });
                
                return true;
              }
              return false;
            }
            
            
            let loadCheckInterval = setInterval(() => {
              if (checkEdgeTierLoaded()) {
                clearInterval(loadCheckInterval);
                setupEventListeners();
              }
            }, 500);
            
            
            function setupEventListeners() {
              document.getElementById('checkAvailability')?.addEventListener('click', function() {
                if (window.EdgeTierChat) {
                  window.EdgeTierChat.isAvailable((error, data) => {
                    if (!error && data) {
                      notifyFlutter('availability:' + data.isAvailable);
                    }
                  });
                }
              });
              
              document.getElementById('showButton')?.addEventListener('click', function() {
                if (window.EdgeTierChat) {
                  window.EdgeTierChat.showButton();
                }
              });
              
              document.getElementById('openChat')?.addEventListener('click', function() {
                if (window.EdgeTierChat) {
                  window.EdgeTierChat.open((error) => {
                    if (!error) {
                      notifyFlutter('chatOpened');
                    }
                  });
                }
              });
            }
          </script>
        </body>
      </html>
    ''';
  }

  Future<void> _checkEdgeTierLoaded() async {
    try {
      final bool isLoaded = await _controller.runJavaScriptReturningResult(
          'window.EdgeTierChat !== undefined') as bool;
      setState(() {
        isEdgeTierLoaded = isLoaded;
      });
      _logger.info('🔎 EdgeTier loaded status: $isEdgeTierLoaded');
    } catch (e) {
      // Handle exceptions silently
      _logger.error('❌ Error checking EdgeTier load status: $e');
    }
  }

  // Public methods that can be called from parent widget
  Future<bool> checkAvailability() async {
    if (!isEdgeTierLoaded) {
      _logger.warning('⚠️ Cannot check availability - EdgeTier not loaded yet');
      return false;
    }
    try {
      _logger.info('🔍 Checking EdgeTier chat availability...');
      await _controller.runJavaScript('''
        if (window.EdgeTierChat) {
          window.EdgeTierChat.isAvailable((error, data) => {
            if (!error && data) {
              notifyFlutter('availability:' + data.isAvailable);
            }
          });
        }
      ''');
      return true;
    } catch (e) {
      _logger.error('❌ Error checking availability: $e');
      return false;
    }
  }

  Future<bool> showChatButton() async {
    if (!isEdgeTierLoaded) {
      _logger.warning('⚠️ Cannot show chat button - EdgeTier not loaded yet');
      return false;
    }
    try {
      _logger.info('👆 Showing EdgeTier chat button...');
      await _controller.runJavaScript('''
        if (window.EdgeTierChat) {
          window.EdgeTierChat.showButton();
        }
      ''');
      return true;
    } catch (e) {
      _logger.error('❌ Error showing chat button: $e');
      return false;
    }
  }

  Future<bool> openChat() async {
    if (!isEdgeTierLoaded) {
      _logger.warning('⚠️ Cannot open chat - EdgeTier not loaded yet');
      return false;
    }
    try {
      _logger.info('📲 Opening EdgeTier chat window nyaa~!');
      await _controller.runJavaScript('''
        if (window.EdgeTierChat) {
          window.EdgeTierChat.open((error) => {
            if (!error) {
              notifyFlutter('chatOpened');
            }
          });
        }
      ''');
      return true;
    } catch (e) {
      _logger.error('❌ Error opening chat: $e');
      return false;
    }
  }

  Future<bool> setOptions(
      {bool? hideMinimiseButton, bool? hideCloseButton}) async {
    if (!isEdgeTierLoaded) {
      _logger.warning('⚠️ Cannot set options - EdgeTier not loaded yet');
      return false;
    }
    final options = <String, dynamic>{};
    if (hideMinimiseButton != null) {
      options['hideMinimiseButton'] = hideMinimiseButton;
    }
    if (hideCloseButton != null) {
      options['hideCloseButton'] = hideCloseButton;
    }
    try {
      _logger.info('⚙️ Setting EdgeTier options: $options');
      await _controller.runJavaScript('''
        if (window.EdgeTierChat) {
          window.EdgeTierChat.setOptions(${options.toString()});
        }
      ''');
      return true;
    } catch (e) {
      _logger.error('❌ Error setting options: $e');
      return false;
    }
  }

  Future<bool> storeVariable(int variableId, dynamic value) async {
    if (!isEdgeTierLoaded) {
      _logger.warning('⚠️ Cannot store variable - EdgeTier not loaded yet');
      return false;
    }
    String valueStr;
    if (value is String) {
      valueStr = '"$value"';
    } else {
      valueStr = value.toString();
    }
    try {
      _logger.info('💾 Storing variable with ID $variableId: $value');
      await _controller.runJavaScript('''
        if (window.EdgeTierChat) {
          window.EdgeTierChat.storeVariable($variableId, $valueStr);
        }
      ''');
      return true;
    } catch (e) {
      _logger.error('❌ Error storing variable: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: WebViewWidget(controller: _controller),
    );
  }
}
