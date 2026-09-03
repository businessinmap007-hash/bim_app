import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cart/application/cart_controller.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';

/// A cart shortcut for the app's main screens — previously the only way to
/// reach the cart was from inside a specific business's own page. Hidden
/// entirely while the cart is empty (an always-visible icon with a "0"
/// badge just adds AppBar clutter for the common case of not shopping);
/// once there's something in it, it shows up right after the notification
/// bell, the same spot a shopping-cart icon sits on any storefront app.
class CartIconButton extends ConsumerWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsCount = ref.watch(cartControllerProvider.select((s) => s.itemsCount));
    if (itemsCount <= 0) return const SizedBox.shrink();

    return IconButton(
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
      icon: Badge(
        label: Text('$itemsCount'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
