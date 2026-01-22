import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../utils/navigation_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedCountry;

  static const List<String> _countries = [
    'United States', 'United Kingdom', 'Canada', 'Australia', 'Germany', 'France', 'Italy', 'Spain',
    'Netherlands', 'Belgium', 'Switzerland', 'Austria', 'Sweden', 'Norway', 'Denmark', 'Finland',
    'Poland', 'Portugal', 'Greece', 'Ireland', 'Czech Republic', 'Hungary', 'Romania', 'Bulgaria',
    'Croatia', 'Slovakia', 'Slovenia', 'Lithuania', 'Latvia', 'Estonia', 'Luxembourg', 'Malta',
    'Cyprus', 'Japan', 'South Korea', 'China', 'India', 'Singapore', 'Malaysia', 'Thailand',
    'Indonesia', 'Philippines', 'Vietnam', 'Taiwan', 'Hong Kong', 'New Zealand', 'South Africa',
    'Brazil', 'Argentina', 'Mexico', 'Chile', 'Colombia', 'Peru', 'Venezuela', 'Ecuador',
    'Uruguay', 'Paraguay', 'Bolivia', 'Panama', 'Costa Rica', 'Guatemala', 'Honduras',
    'El Salvador', 'Nicaragua', 'Dominican Republic', 'Jamaica', 'Trinidad and Tobago', 'Bahamas',
    'Barbados', 'Belize', 'Guyana', 'Suriname', 'Egypt', 'Nigeria', 'Kenya', 'Ghana',
    'Tanzania', 'Uganda', 'Ethiopia', 'Morocco', 'Algeria', 'Tunisia', 'Libya', 'Sudan',
    'Saudi Arabia', 'United Arab Emirates', 'Israel', 'Turkey', 'Lebanon', 'Jordan', 'Kuwait',
    'Qatar', 'Oman', 'Bahrain', 'Iraq', 'Iran', 'Pakistan', 'Bangladesh', 'Sri Lanka',
    'Nepal', 'Myanmar', 'Cambodia', 'Laos', 'Mongolia', 'Kazakhstan', 'Uzbekistan', 'Ukraine',
    'Russia', 'Belarus', 'Moldova', 'Georgia', 'Armenia', 'Azerbaijan', 'Kyrgyzstan',
    'Tajikistan', 'Turkmenistan', 'Afghanistan', 'Iceland', 'Liechtenstein', 'Monaco',
    'San Marino', 'Vatican City', 'Andorra', 'Albania', 'Bosnia and Herzegovina',
    'North Macedonia', 'Serbia', 'Montenegro', 'Kosovo', 'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      country: _selectedCountry ?? '',
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      if (mounted) {
        NavigationHelper.showSuccessDialog(
          context,
          result['message'] as String? ?? 'Registration successful!',
        );
        // Navigate to login after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/login');
          }
        });
      }
    } else {
      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          result['message'] as String,
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Navigate back to login instead of closing app
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/login');
          }
        }
      },
      child: Scaffold(
        body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF00D09E), // Main Green background
        child: Stack(
          children: [
            // Back Button
            Positioned(
              top: 50,
              left: 24,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF093030),
                ),
                onPressed: () {
                  context.go('/login');
                },
              ),
            ),

            // Title
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    height: 22 / 15,
                    color: Color(0xFF093030),
                  ),
                ),
              ),
            ),

            // Main Content Card (Base Shape)
            Positioned(
              top: 117,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3), // Background Green White and Letters
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),

                        // Name label
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 29, bottom: 8),
                          child: const Text(
                            'Full Name',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 22 / 15,
                              color: Color(0xFF093030), // Letters and Icons
                            ),
                          ),
                        ),

                        // Name Input Field
                        Container(
                          width: 356,
                          height: 41,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1a1a1a),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFDFF7E2),
                              hintText: 'Enter your full name',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 14 / 16,
                                color: Color(0xFF093030).withOpacity(0.45),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Email label
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 29, bottom: 8),
                          child: const Text(
                            'Email',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 22 / 15,
                              color: Color(0xFF093030), // Letters and Icons
                            ),
                          ),
                        ),

                        // Email Input Field
                        Container(
                          width: 356,
                          height: 41,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1a1a1a),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFDFF7E2),
                              hintText: 'example@example.com',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 14 / 16,
                                color: Color(0xFF093030).withOpacity(0.45),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Country label
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 29, bottom: 8),
                          child: const Text(
                            'Country',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 22 / 15,
                              color: Color(0xFF093030), // Letters and Icons
                            ),
                          ),
                        ),

                        // Country Dropdown Field
                        Container(
                          width: 356,
                          height: 41,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedCountry,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1a1a1a),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFDFF7E2),
                              hintText: 'Select your country',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 14 / 16,
                                color: Color(0xFF093030).withOpacity(0.45),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _countries.map((String country) {
                              return DropdownMenuItem<String>(
                                value: country,
                                child: Text(country),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCountry = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your country';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password label
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 29, bottom: 8),
                          child: const Text(
                            'Password',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 22 / 15,
                              color: Color(0xFF093030), // Letters and Icons
                            ),
                          ),
                        ),

                        // Password Input Field
                        Container(
                          width: 356,
                          height: 41,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1a1a1a),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFDFF7E2),
                              hintText: '••••••••',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 14 / 12, // 117% line height
                                color: const Color(0xFF0E3E3E).withOpacity(0.45), // Dark Mode Green bar
                                letterSpacing: 4.2, // 0.7em spacing
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Color(0xFF0E3E3E).withOpacity(0.6),
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Confirm Password label
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 29, bottom: 8),
                          child: const Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 22 / 15,
                              color: Color(0xFF093030), // Letters and Icons
                            ),
                          ),
                        ),

                        // Confirm Password Input Field
                        Container(
                          width: 356,
                          height: 41,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1a1a1a),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFDFF7E2),
                              hintText: '••••••••',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 14 / 12, // 117% line height
                                color: const Color(0xFF0E3E3E).withOpacity(0.45), // Dark Mode Green bar
                                letterSpacing: 4.2, // 0.7em spacing
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Color(0xFF0E3E3E).withOpacity(0.6),
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Register Button
                        if (_isLoading)
                          const CircularProgressIndicator(
                            color: Color(0xFF00D09E),
                          )
                        else
                          Container(
                            width: 207,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D09E), // Main Green
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextButton(
                              onPressed: _handleRegister,
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 22 / 20, // 110% line height
                                  color: Color(0xFF093030), // Letters and Icons
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 50),

                        // Already have an account? Sign In
                        GestureDetector(
                          onTap: () {
                            context.go('/login');
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'League Spartan',
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                height: 15 / 13,
                                color: Color(0xFF093030), // Default color for normal text
                              ),
                              children: const [
                                TextSpan(
                                  text: "Already have an account? ",
                                ),
                                TextSpan(
                                  text: "Sign In",
                                  style: TextStyle(
                                    color: Colors.blue, // Blue color for "Sign In"
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
