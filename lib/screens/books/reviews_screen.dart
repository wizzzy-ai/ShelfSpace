import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/book.dart';

class ReviewsScreen extends StatefulWidget {
  final Book book;

  const ReviewsScreen({
    super.key,
    required this.book,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final List<_MockReview> _reviews = [
    const _MockReview(
      name: 'James',
      rating: 5,
      text:
          'A really enjoyable read. The story kept me interested from beginning to end.',
      time: '2 days ago',
      likes: 24,
    ),
    const _MockReview(
      name: 'Sarah',
      rating: 4,
      text:
          'Well written and worth reading. I would definitely recommend it.',
      time: '1 week ago',
      likes: 12,
    ),
    const _MockReview(
      name: 'Michael',
      rating: 5,
      text:
          'One of the best books I have read recently. Definitely worth the price.',
      time: '2 weeks ago',
      likes: 18,
    ),
  ];

  void _showWriteReviewSheet() {
    int selectedRating = 0;
    final reviewController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                    MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Write a Review',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.book.title,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Your Rating',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(
                        5,
                        (index) {
                          final rating = index + 1;

                          return IconButton(
                            onPressed: () {
                              setSheetState(() {
                                selectedRating = rating;
                              });
                            },
                            icon: Icon(
                              rating <= selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 34,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: reviewController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Your Review',
                        hintText:
                            'Tell other readers what you thought...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: selectedRating == 0 ||
                                reviewController.text.trim().isEmpty
                            ? null
                            : () {
                                Navigator.pop(sheetContext);

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Your review has been submitted.',
                                    ),
                                  ),
                                );
                              },
                        child: const Text('Submit Review'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rating = widget.book.rating;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Ratings & Reviews'),
        backgroundColor: AppColors.cream,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showWriteReviewSheet,
        backgroundColor: AppColors.burgundy,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Write Review'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          100,
        ),
        children: [
          _buildRatingSummary(rating),
          const SizedBox(height: 22),
          const Text(
            'Customer Reviews',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: _ReviewCard(
                review: review,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(double rating) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Column(
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.burgundy,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating.round()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 17,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.book.reviewCount} reviews',
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: [
                _RatingBar(
                  stars: 5,
                  percentage: 0.76,
                ),
                _RatingBar(
                  stars: 4,
                  percentage: 0.17,
                ),
                _RatingBar(
                  stars: 3,
                  percentage: 0.04,
                ),
                _RatingBar(
                  stars: 2,
                  percentage: 0.02,
                ),
                _RatingBar(
                  stars: 1,
                  percentage: 0.01,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final double percentage;

  const _RatingBar({
    required this.stars,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 6,
      ),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(
            Icons.star_rounded,
            size: 13,
            color: Colors.amber,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 6,
                backgroundColor: AppColors.border,
                color: AppColors.burgundy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final _MockReview review;

  const _ReviewCard({
    required this.review,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final likes =
        widget.review.likes + (_liked ? 1 : 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor:
                    AppColors.burgundy.withValues(
                  alpha: 0.10,
                ),
                child: Text(
                  widget.review.name[0],
                  style: const TextStyle(
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.review.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.review.time,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: index < widget.review.rating
                        ? Colors.amber
                        : AppColors.border,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.review.text,
            style: const TextStyle(
              color: AppColors.mutedText,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _liked = !_liked;
                  });
                },
                icon: Icon(
                  _liked
                      ? Icons.thumb_up_rounded
                      : Icons.thumb_up_outlined,
                  size: 17,
                  color: _liked
                      ? AppColors.burgundy
                      : AppColors.mutedText,
                ),
                label: Text(
                  '$likes',
                  style: TextStyle(
                    color: _liked
                        ? AppColors.burgundy
                        : AppColors.mutedText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MockReview {
  final String name;
  final int rating;
  final String text;
  final String time;
  final int likes;

  const _MockReview({
    required this.name,
    required this.rating,
    required this.text,
    required this.time,
    required this.likes,
  });
}