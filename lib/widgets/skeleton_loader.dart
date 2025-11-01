import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A reusable skeleton loader widget with shimmer effect
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey.shade300,
      highlightColor: highlightColor ?? Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: shape == BoxShape.circle
              ? (baseColor?.withOpacity(0.3) ?? Colors.white.withOpacity(0.3))
              : (baseColor ?? Colors.grey.shade300),
          borderRadius: borderRadius,
          shape: shape,
        ),
      ),
    );
  }
}

/// A generic list skeleton loader
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets? padding;
  final Widget Function(BuildContext, int)? itemBuilder;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 60.0,
    this.padding,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: itemBuilder ??
          (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SkeletonBox(width: 40, height: 40, borderRadius: BorderRadius.circular(8)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: double.infinity, height: 16),
                          const SizedBox(height: 8),
                          SkeletonBox(width: 100, height: 12),
                        ],
                      ),
                    ),
                    SkeletonBox(width: 80, height: 16),
                  ],
                ),
              ),
    );
  }
}

/// A card skeleton loader
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget child;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

/// A stats skeleton loader with icons
class SkeletonStats extends StatelessWidget {
  final int count;

  const SkeletonStats({
    super.key,
    this.count = 3,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    for (int i = 0; i < count; i++) {
      if (i > 0) {
        widgets.add(Container(width: 1, height: 80, color: Colors.grey.withOpacity(0.2)));
      }
      widgets.add(
        Expanded(
          child: Column(
            children: [
              SkeletonBox(width: 50, height: 50, borderRadius: BorderRadius.circular(12)),
              const SizedBox(height: 8),
              SkeletonBox(width: 80, height: 12),
              const SizedBox(height: 4),
              SkeletonBox(width: 60, height: 16),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: widgets),
    );
  }
}

