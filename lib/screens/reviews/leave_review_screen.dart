import 'dart:io';
import 'package:flutter/material.dart';
import 'package:maisonel_v02/l10n/app_localizations.dart';
import '../../theme.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

class LeaveReviewScreen extends StatefulWidget {
  final Property property;
  final String orderId;

  const LeaveReviewScreen({
    super.key,
    required this.property,
    required this.orderId,
  });

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  final _commentController = TextEditingController();
  double _rating = 0;
  bool _isLoading = false;

  bool _isFilePath(String path) {
    if (path.startsWith('file://')) return true;
    if (path.startsWith('/') || path.startsWith('\\')) return true;
    return RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(path);
  }

  String? _resolveImagePath(String rawPath) {
    if (_isFilePath(rawPath)) return rawPath;
    return ApiService.getImageUrl(rawPath);
  }

  Widget _buildImageFallback() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[300],
      child: Icon(
        Icons.image_not_supported,
        size: 28,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildPropertyImage() {
    final rawPath =
        widget.property.images.isNotEmpty ? widget.property.images.first : null;
    if (rawPath == null || rawPath.isEmpty) {
      return _buildImageFallback();
    }

    final resolvedPath = _resolveImagePath(rawPath);
    if (resolvedPath == null || resolvedPath.isEmpty) {
      return _buildImageFallback();
    }

    if (_isFilePath(resolvedPath)) {
      final file = resolvedPath.startsWith('file://')
          ? File.fromUri(Uri.parse(resolvedPath))
          : File(resolvedPath);
      return Image.file(
        file,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImageFallback(),
      );
    }

    return Image.network(
      resolvedPath,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
    );
  }

  void _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectRating)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.storeRating(
        widget.orderId,
        _rating.toInt(),
        _commentController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.reviewSubmitted),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.reviewFailed(e.toString()),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.leaveReview)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Property Summary
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: _buildPropertyImage(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.property.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.property.location,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Rating Stars
            Text(
              AppLocalizations.of(context)!.howWasStay,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Comment
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.shareExperience,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            CustomButton(
              text: AppLocalizations.of(context)!.submitReview,
              onPressed: _submitReview,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
