import 'package:flutter/material.dart';
import '../../utils/navigation_helper.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _isAccepted = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _acceptTerms() {
    if (!_isAccepted) {
      NavigationHelper.showSnackBar(
        context,
        'Please accept the terms and conditions first',
        backgroundColor: Colors.orange,
      );
      return;
    }

    NavigationHelper.showSnackBar(
      context,
      'Terms and conditions accepted',
    );
    Navigator.of(context).pop(true); // Return true to indicate acceptance
  }

  void _openWebsite() {
    // TODO: Implement URL launcher for website
    NavigationHelper.showSnackBar(
      context,
      'Opening website: www.finwiseapp.de',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 430,
        height: 932,
        decoration: const BoxDecoration(
          color: Color(0xFF00D09E),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        child: Stack(
          children: [
            // Status bar
            Positioned(
              left: 0,
              top: 0,
              width: 430,
              height: 32,
              child: Stack(
                children: [
                  Positioned(
                    left: 37,
                    top: 9,
                    child: SizedBox(
                      width: 30,
                      height: 14,
                      child: Text(
                        '16:04',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'League Spartan',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Back button
            Positioned(
              left: 38,
              top: 69,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  width: 19,
                  height: 16,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFF1FFF3),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Title
            const Positioned(
              left: 92,
              top: 64,
              child: SizedBox(
                width: 246,
                child: Text(
                  'Terms And Conditions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
                ),
              ),
            ),

            // Terms content (scrollable)
            Positioned(
              left: 37,
              top: 169,
              child: SizedBox(
                width: 356,
                height: 489,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Est fugiat assumenda aut reprehenderit\n',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: '\nLorem ipsum dolor sit amet. Et odio officia aut voluptate internos est omnis vitae ut architecto sunt non tenetur fuga ut provident vero. Quo aspernatur facere et consectetur ipsum et facere corrupti est asperiores facere. Est fugiat assumenda aut reprehenderit voluptatem sed.\n\n',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                            height: 1.15,
                          ),
                        ),
                        TextSpan(
                          text: 'Ea voluptates omnis aut sequi sequi.\nEst dolore quae in aliquid ducimus et autem repellendus.\nAut ipsum Quis qui porro quasi aut minus placeat!\nSit consequatur neque ab vitae facere.\n',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                            height: 1.15,
                          ),
                        ),
                        TextSpan(
                          text: '\nAut quidem accusantium nam alias autem eum officiis placeat et omnis autem id officiis perspiciatis qui corrupti officia eum aliquam provident. Eum voluptas error et optio dolorum cum molestiae nobis et odit molestiae quo magnam impedit sed fugiat nihil non nihil vitae.\n\n',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                            height: 1.15,
                          ),
                        ),
                        TextSpan(
                          text: 'Aut fuga sequi eum voluptatibus provident.\nEos consequuntur voluptas vel amet eaque aut dignissimos velit.\n',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                            height: 1.15,
                          ),
                        ),
                        TextSpan(
                          text: '\nVel exercitationem quam vel eligendi rerum At harum obcaecati et nostrum beatae? Ea accusantium dolores qui rerum aliquam est perferendis mollitia et ipsum ipsa qui enim autem At corporis sunt. Aut odit quisquam est reprehenderit itaque aut accusantium dolor qui neque repellat.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),

            // Website link section
            Positioned(
              left: 37,
              top: 675,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 309,
                    height: 18,
                    child: Text(
                      'Read the terms and conditions in more detail at\n',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w300,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _openWebsite,
                    child: const Text(
                      'www.finwiseapp.de',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Color(0xFF3299FF),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Acceptance checkbox and text
            Positioned(
              left: 42,
              top: 725,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAccepted = !_isAccepted;
                      });
                    },
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        color: _isAccepted ? Colors.black : Colors.transparent,
                      ),
                      child: _isAccepted
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 309,
                    height: 18,
                    child: Text(
                      'I accept all the terms and conditions',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w300,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Accept button
            Positioned(
              left: 114,
              top: 762,
              child: GestureDetector(
                onTap: _acceptTerms,
                child: Container(
                  width: 202,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D09E),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Accept',
                    style: TextStyle(
                      color: Color(0xFF093030),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                    ),
                  ),
                ),
              ),
            ),

            // Notification icon
            Positioned(
              left: 364,
              top: 61,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.all(Radius.circular(25.71)),
                ),
                child: Center(
                  child: Container(
                    width: 14.57,
                    height: 18.86,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF093030),
                        width: 1.29,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            Positioned(
              left: 0,
              top: 824,
              width: 430,
              height: 108,
              child: Container(
                padding: const EdgeInsets.fromLTRB(60, 36, 60, 41),
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Home icon
                    Container(
                      width: 25,
                      height: 31,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Analysis icon
                    Container(
                      width: 31,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Transactions icon
                    Container(
                      width: 33,
                      height: 25,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Categories icon
                    Container(
                      width: 27,
                      height: 23,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Profile icon (active)
                    Stack(
                      children: [
                        Positioned(
                          left: -17,
                          top: -12,
                          child: Container(
                            width: 57,
                            height: 53,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D09E),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 27,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF052224),
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

