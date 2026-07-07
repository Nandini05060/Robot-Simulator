import 'package:flutter/material.dart';

class SmoothEntranceTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double slideOffset;

  const SmoothEntranceTransition({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.slideOffset = 0.05,
  }) : super(key: key);

  @override
  State<SmoothEntranceTransition> createState() => _SmoothEntranceTransitionState();
}

class _SmoothEntranceTransitionState extends State<SmoothEntranceTransition> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, widget.slideOffset),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
