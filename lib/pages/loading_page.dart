import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  final String? message;
  final bool showGif;
  final String? gifPath;
  
  const LoadingPage({
    super.key, 
    this.message, 
    this.showGif = false,
    this.gifPath,
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF181A20);
    const cardColor = Color(0xFF23242B);
    const accentColor = Color.fromARGB(255, 58, 136, 237);
    const mainTextColor = Colors.white;
    const secondaryTextColor = Color(0xFFB0B0B0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Loading animation
              if (widget.showGif && widget.gifPath != null)
                Image.asset(
                  widget.gifPath!,
                  width: 80,
                  height: 80,
                )
              else
                AnimatedBuilder(
                  animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [accentColor, Color.fromARGB(255, 102, 140, 255)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: mainTextColor,
                            size: 25,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 12),
              
              // Loading text
              Text(
                widget.message ?? 'Loading delicious recipes...',
                style: const TextStyle(
                  color: mainTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 6),
              
              // Subtitle
              const Text(
                'Please wait while we prepare your culinary journey',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Progress indicator
              SizedBox(
                width: 150,
                child: LinearProgressIndicator(
                  backgroundColor: cardColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for inline loading (smaller version)
class InlineLoading extends StatefulWidget {
  final String? message;
  final double size;
  
  const InlineLoading({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  State<InlineLoading> createState() => _InlineLoadingState();
}

class _InlineLoadingState extends State<InlineLoading> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color.fromARGB(255, 58, 136, 237);
    const mainTextColor = Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(width: 12),
          Text(
            widget.message!,
            style: const TextStyle(
              color: mainTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
} 