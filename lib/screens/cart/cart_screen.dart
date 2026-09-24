import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/cart_service.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icons/app_icon.png',
              height: 32,
              width: 32,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.menu_book_rounded,
                  size: 32,
                  color: AppColors.burgundy,
                );
              },
            ),
            const SizedBox(width: 8),
            const Text('My Cart'),
          ],
        ),
        backgroundColor: AppColors.cream,
        elevation: 0,
        actions: [
          AnimatedBuilder(
            animation: CartService.instance,
            builder: (context, _) {
              final count = CartService.instance.itemCount;

              if (count == 0) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.burgundy.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count ${count == 1 ? 'item' : 'items'}',
                      style: const TextStyle(
                        color: AppColors.burgundy,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: CartService.instance,
        builder: (context, _) {
          final cart = CartService.instance;
          final items = cart.items;

          if (items.isEmpty) {
            return const _EmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    20,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) {
                    return const SizedBox(height: 12);
                  },
                  itemBuilder: (context, index) {
                    return _CartItemCard(
                      item: items[index],
                    );
                  },
                ),
              ),
              _CartSummary(),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;

  const _CartItemCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final book = item.book;
    final cart = CartService.instance;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              book.coverUrl,
              width: 88,
              height: 118,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 88,
                  height: 118,
                  color: AppColors.border,
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.mutedText,
                    size: 32,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  '₦${book.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.burgundy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove_rounded,
                      onPressed: () {
                        cart.decreaseQuantity(book);
                      },
                    ),
                    Container(
                      width: 38,
                      height: 32,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add_rounded,
                      onPressed: () {
                        cart.increaseQuantity(book);
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: () {
                        cart.remove(book);

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              duration: const Duration(
                                milliseconds: 900,
                              ),
                              content: Text(
                                '${book.title} removed from cart',
                              ),
                            ),
                          );
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: AppColors.burgundy,
          ),
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              label: 'Subtotal',
              value: '₦${cart.subtotal.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Delivery',
              value: '₦${cart.deliveryFee.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 12),
            const Divider(
              color: AppColors.border,
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Total',
              value: '₦${cart.total.toStringAsFixed(0)}',
              isTotal: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CheckoutScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Proceed to Checkout',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal
                ? AppColors.dark
                : AppColors.mutedText,
            fontSize: isTotal ? 16 : 13,
            fontWeight:
                isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: isTotal
                ? AppColors.burgundy
                : AppColors.dark,
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.burgundy.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.burgundy,
                size: 46,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add books you want to purchase and they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedText,
                height: 1.5,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
