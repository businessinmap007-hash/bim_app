import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/cart_icon_button.dart';
import '../../../../shared/widgets/chat_icon_button.dart';
import '../../../../shared/widgets/create_post_button.dart';
import '../../../../shared/widgets/notification_bell_button.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../categories/presentation/screens/all_categories_screen.dart';
import 'business_home_screen.dart';
import 'customer_home_screen.dart';
import 'my_services_screen.dart';

/// The persistent shell for every signed-in account. Below
/// [_threePaneMinWidth] this is the mobile/tablet bottom-nav Scaffold —
/// Home / Categories / My Services, icon-only (no labels, so the Home tab's
/// own icon can be the account's own avatar instead of a generic house — the
/// bar tells you which account is signed in at a glance). Only the Home
/// tab's content differs by account type (the business dashboard vs the
/// category feed); Categories (browsing + cross-category search, now
/// inline instead of its own tab) and My Services (a person's own activity
/// — bookings, orders, wallet, ...) are the same for both, since neither is
/// a business-vs-customer concern. Account editing and settings stay in
/// AppDrawer (its own header IS the door to the account) — not a fourth tab
/// — since jumping to your own account isn't a "destination" the way these
/// three are.
///
/// An [IndexedStack] keeps all three tabs mounted so switching tabs never
/// re-fetches — the tradeoff is that all three start loading as soon as the
/// shell mounts, which is fine at this scale (a handful of lightweight
/// requests, not a heavy screen).
///
/// At [_threePaneMinWidth] and above, [_DesktopHomeShell] replaces this with
/// a 3-column layout instead (drawer content / Home+Categories / My
/// Services, all visible at once, Facebook-style) — see its own doc comment.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

/// Deliberately its own constant, not [Breakpoints.desktop] (1024) — three
/// fixed-width panels (280 + 320 + a sane center minimum) need more room
/// than that to avoid the exact "not enough width" bug that motivated this
/// shell in the first place (see [CategoryRootsGrid]). Between 1024 and this
/// threshold, the plain mobile-style shell below keeps applying — that's
/// already today's working behavior for that range, not a regression.
const _threePaneMinWidth = 1200.0;

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isBusiness = authState is AuthSignedIn && authState.user.isBusiness;
    final avatarUrl = authState is AuthSignedIn
        ? (authState.user.logoUrl ?? authState.user.imageUrl)
        : null;

    if (MediaQuery.sizeOf(context).width >= _threePaneMinWidth) {
      return _DesktopHomeShell(isBusiness: isBusiness);
    }

    final tabs = [
      isBusiness ? const BusinessHomeScreen() : const CustomerHomeScreen(),
      const AllCategoriesScreen(),
      const MyServicesScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        indicatorColor: AppColors.accentGold.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          NavigationDestination(
            icon: _HomeTabIcon(avatarUrl: avatarUrl, selected: _index == 0),
            label: '',
          ),
          const NavigationDestination(
            icon: Icon(Icons.category_outlined, size: 28),
            selectedIcon: Icon(Icons.category_rounded, size: 28),
            label: '',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined, size: 28),
            selectedIcon: Icon(Icons.grid_view_rounded, size: 28),
            label: '',
          ),
        ],
      ),
    );
  }
}

/// The Home tab's own icon: the signed-in account's avatar when it has one,
/// a ring around it while selected — same "this is you" affordance a house
/// icon can't give.
class _HomeTabIcon extends StatelessWidget {
  final String? avatarUrl;
  final bool selected;
  const _HomeTabIcon({required this.avatarUrl, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: selected
            ? Border.all(color: AppColors.accentGold, width: 2)
            : null,
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? CachedNetworkImage(imageUrl: avatarUrl!, fit: BoxFit.cover)
            : Container(
                color: AppColors.accentGold.withValues(alpha: 0.15),
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: AppColors.primaryNavy,
                ),
              ),
      ),
    );
  }
}

/// The wide-screen shell: a 3-column layout instead of a bottom-nav tab
/// switch, matching the desktop pattern of Facebook/LinkedIn-style apps —
/// the freed-up width on a wide window goes to persistent side panels, not
/// to a stretched-out center (that's what caused the category grid bug this
/// whole shell was built to avoid).
///
/// A plain [Row] with no `textDirection` override resolves against the
/// ambient [Directionality] (set by [MaterialApp] from the active locale),
/// so `[drawer sidebar, center, services sidebar]` automatically places the
/// drawer sidebar on the reading-start edge — right in Arabic, left in
/// English — with no manual RTL check needed.
class _DesktopHomeShell extends StatefulWidget {
  final bool isBusiness;
  const _DesktopHomeShell({required this.isBusiness});

  @override
  State<_DesktopHomeShell> createState() => _DesktopHomeShellState();
}

class _DesktopHomeShellState extends State<_DesktopHomeShell> {
  int _centerTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(width: 280, child: AppDrawerContent(isModal: false)),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  _DesktopTopBar(
                    isBusiness: widget.isBusiness,
                    centerTab: _centerTab,
                    onTabChanged: (value) => setState(() => _centerTab = value),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: IndexedStack(
                          index: _centerTab,
                          children: [
                            widget.isBusiness
                                ? const BusinessHomeBody()
                                : const CustomerHomeBody(),
                            const AllCategoriesBody(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            const SizedBox(width: 320, child: MyServicesBody()),
          ],
        ),
      ),
    );
  }
}

/// Not a real [AppBar] — a plain top row shared by both center-pane tabs, so
/// switching between Home and Categories doesn't also swap out (or
/// duplicate) the title/actions. The 4 action buttons stay visible
/// regardless of which tab is active: chat/notifications/cart are
/// account-global utilities, not Home-specific — they only ever lived on
/// Home's own AppBar on mobile because Categories/My Services never had an
/// actions row of their own, not because the actions are semantically tied
/// to the feed. Keeping them always visible also avoids layout jitter on
/// every tab switch.
class _DesktopTopBar extends StatelessWidget {
  final bool isBusiness;
  final int centerTab;
  final ValueChanged<int> onTabChanged;

  const _DesktopTopBar({
    required this.isBusiness,
    required this.centerTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SegmentedButton<int>(
            segments: [
              ButtonSegment(
                value: 0,
                label: Text(
                  isBusiness ? l10n.homeBusinessTitle : l10n.homeCustomerTitle,
                ),
              ),
              ButtonSegment(value: 1, label: Text(l10n.navCategories)),
            ],
            selected: {centerTab},
            onSelectionChanged: (values) => onTabChanged(values.first),
          ),
          const Spacer(),
          const CreatePostButton(),
          const ChatIconButton(),
          const NotificationBellButton(),
          const CartIconButton(),
        ],
      ),
    );
  }
}
