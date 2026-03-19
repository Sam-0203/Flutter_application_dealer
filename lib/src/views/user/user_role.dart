import 'package:dealershub_/src/utils/route/route.dart';
import 'package:flutter/material.dart';

class UserRole extends StatelessWidget {
  final String authType;
  const UserRole({super.key, required this.authType});

  @override
  Widget build(BuildContext context) {
    print('Auth Type Received: $authType');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/placeholders/user_Head & Subhead.png',
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// DEALER CARD
              Expanded(
                child: _roleCard(
                  image: 'assets/placeholders/dealers_palceholders.png',
                  roleType: 'dealer',
                  onTap: (String roleType) {
                    // Handle selection here
                    print('Selected Dealer: $roleType');
                    if (authType == 'register') {
                      Navigator.pushReplacementNamed(
                        context,
                        NewUserSignup, // or whatever your route constant is named
                        arguments: {
                          'authType': authType,
                          'roleType': roleType,
                        }, //pass the String as arguments
                      );
                    } else {
                      Navigator.pushReplacementNamed(
                        context,
                        userLogin, // or whatever your route constant is named
                        arguments: {'authType': authType, 'roleType': roleType},
                        //pass the String as arguments
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              /// AGENT CARD
              Expanded(
                child: _roleCard(
                  image: 'assets/placeholders/Agent_placeholders.png',
                  roleType: 'agent',
                  onTap: (String roleType) {
                    // Handle selection here
                    print('Selected Agent: $roleType');

                    if (authType == 'register') {
                      Navigator.pushReplacementNamed(
                        context,
                        NewUserSignup, // or whatever your route constant is named
                        arguments: {
                          'authType': authType,
                          'roleType': roleType,
                        }, //pass the String as arguments
                      );
                    } else {
                      Navigator.pushReplacementNamed(
                        context,
                        userLogin, // or whatever your route constant is named
                        arguments: {'authType': authType, 'roleType': roleType},
                        //pass the String as arguments
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard({
    required String image,
    required String roleType,
    required Function(String) onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(roleType),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Center(child: Image.asset(image, fit: BoxFit.contain)),
      ),
    );
  }
}
