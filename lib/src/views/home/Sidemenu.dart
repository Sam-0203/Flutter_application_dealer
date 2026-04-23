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
                                    _buildRoleBadge('Dealer'),
                                  ],
                                ),

                                Text(
                                  data?.mobile ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    data?.email ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
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
                                    _buildRoleBadge('Agent'),
                                  ],
                                ),

                                Text(
                                  data?.mobile ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    data?.email ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
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
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<LogoutViewModel>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                OnBoardingscreen5,
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

Widget _buildRoleBadge(String role) {
  return Container(
    margin: const EdgeInsets.only(top: 6),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      role.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 1,
      ),
    ),
  );
}
