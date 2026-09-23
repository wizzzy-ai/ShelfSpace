import '../models/book.dart';

class MockBookService {
  MockBookService._();

  static const List<Book> books = [
    Book(
      id: '1',
      title: 'The Silent Patient',
      author: 'Alex Michaelides',
      genre: 'Thriller',
      description:
          'A psychological thriller about a woman whose refusal to speak after a shocking crime captures the attention of a determined therapist.',
      coverUrl:
          'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=600',
      price: 8500,
      rating: 4.7,
      reviewCount: 1240,
      isBestseller: true,
      isFeatured: true,
    ),
    Book(
      id: '2',
      title: 'Atomic Habits',
      author: 'James Clear',
      genre: 'Self Development',
      description:
          'A practical guide to building good habits, breaking bad ones, and making small changes that create remarkable results.',
      coverUrl:
          'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=600',
      price: 7200,
      rating: 4.8,
      reviewCount: 2480,
      isBestseller: true,
    ),
    Book(
      id: '3',
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      genre: 'Classic',
      description:
          'A classic American novel exploring ambition, love, wealth, and the American dream.',
      coverUrl:
          'https://images.unsplash.com/photo-1511108690759-009324a90311?w=600',
      price: 5500,
      rating: 4.5,
      reviewCount: 890,
      isBestseller: true,
    ),
    Book(
      id: '4',
      title: 'The Alchemist',
      author: 'Paulo Coelho',
      genre: 'Fiction',
      description:
          'A philosophical story about following your dreams and discovering your purpose.',
      coverUrl:
          'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600',
      price: 6000,
      rating: 4.7,
      reviewCount: 1760,
      isNewArrival: true,
    ),
    Book(
      id: '5',
      title: 'Ikigai',
      author: 'Héctor García',
      genre: 'Lifestyle',
      description:
          'A guide to discovering the Japanese concept of purpose and living a more meaningful life.',
      coverUrl:
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600',
      price: 6800,
      rating: 4.6,
      reviewCount: 940,
      isNewArrival: true,
    ),
  ];
}