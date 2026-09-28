import 'package:flutter/material.dart';

import '../models/book.dart';
import 'featured_book_card.dart';

class FeaturedBookBanner extends FeaturedBookCard {
  const FeaturedBookBanner({
    super.key,
    required Book book,
    VoidCallback? onTap,
  }) : super(
          book: book,
          onTap: onTap,
        );
}
