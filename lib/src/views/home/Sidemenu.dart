import 'package:dealershub_/src/utils/route/route.dart';
import 'package:dealershub_/src/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SideBarMenu extends StatefulWidget {
  const SideBarMenu({super.key, this.role, required this.onFavoritesTap});
  final String? role;
  final VoidCallback onFavoritesTap;

  @override
  State<SideBarMenu> createState() => _SideBarMenuState();
}

class _SideBarMenuState extends State<SideBarMenu> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.role == 'dealer') {
        context.read<DealerProfileViewModel>().fetchDealerProfile();
      } else {
        context.read<AgentProfileViewModel>().fetchAgentProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Top content (scrollable if needed)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xffF47B39)),
                  child: widget.role == 'dealer'
                      ? Consumer<DealerProfileViewModel>(
                          builder: (context, vm, child) {
                            if (vm.isLoading) {
                              return Shimmer.fromColors(
                                baseColor: Colors.orange.shade300,
                                highlightColor: Colors.orange.shade100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      height: 16,
                                      width: 120,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 14,
                                      width: 100,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              );
                            }

                            final data = vm.profile?.data;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      data?.dealershipName ?? 'Dealer',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // 🔥 ADD THIS
                                    // _buildRoleBadge('Dealer'),
                                    if (data?.isVerified == true) ...[
                                      _buildRoleBadge(),
                                    ],
                                  ],
                                ),

                                Text(
                                  data?.mobile ?? 'xxxxx xxxxx',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    data?.email ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : Consumer<AgentProfileViewModel>(
                          builder: (context, vm, child) {
                            if (vm.isLoading) {
                              return Shimmer.fromColors(
                                baseColor: Colors.orange.shade300,
                                highlightColor: Colors.orange.shade100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      height: 16,
                                      width: 120,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 14,
                                      width: 100,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              );
                            }

                            final data = vm.profile?.data;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      data?.contactPerson ?? 'Agent',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // 🔥 ADD THIS
                                    // _buildRoleBadge('Agent'),
                                    if (data?.isVerified == true) ...[
                                      _buildRoleBadge(),
                                    ],
                                  ],
                                ),

                                Text(
                                  data?.mobile ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    data?.email ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),

                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('My Favorites'),
                  onTap: () {
                    Navigator.pop(context); // close drawer first
                    widget.onFavoritesTap();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // 🔴 Logout at bottoms
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  barrierColor: Colors.black54,
                  builder: (ctx) => Dialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Avatar row
                          Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFEF0E7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      size: 26,
                                      color: Color(0xffF47B39),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffF47B39),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Log out of DealersHub?',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Your session will end.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Info box
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: Color(0xffF47B39),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "You'll be redirected to the sign-in screen. Your favourites and data will be saved.",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      height: 1.55,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    foregroundColor: Colors.grey.shade600,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffF47B39),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Log out',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                if (confirmed == true) {
                  final success = await context
                      .read<LogoutViewModel>()
                      .logout();

                  if (!mounted) return;

                  if (success) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      OnBoardingscreen5,
                      (route) => false,
                    );
                  } else {
                    // API failed but local cleared — still navigate out
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      OnBoardingscreen5,
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// Widget _buildRoleBadge(String role) {
//   return Container(
//     margin: const EdgeInsets.only(top: 6),
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//     decoration: BoxDecoration(
//       color: Colors.white.withOpacity(0.2),
//       borderRadius: BorderRadius.circular(20),
//     ),
//     child: Text(
//       role.toUpperCase(),
//       style: TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//         letterSpacing: 1,
//       ),
//     ),
//   );
// }

Widget _buildRoleBadge() {
  return const Icon(
    Icons.verified,
    color: Colors.white, // Blue verified badge
    size: 20,
  );
}
