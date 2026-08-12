import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_strings.dart';
import '../../../app/asset_paths.dart';
import '../models/onboarding_model.dart';
import '../widgets/intro_widget.dart';
import 'sign_in_screen.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  static const String routeName = '/introduction';

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<IntroductionModel> _introductionPages = [
    IntroductionModel(
      title: 'Welcome to',
      highlightedTitle: AppStrings.appName,
      description: 'Simple, fast and secure messaging for everyone.',
      imagePath: AssetPaths.illustration,
    ),
    IntroductionModel(
      title: 'Chat in',
      highlightedTitle: 'Real Time',
      description:
          'Send messages, photos and files instantly to the people who matter.',
      imagePath: AssetPaths.illustration1,
    ),
    IntroductionModel(
      title: 'Online or',
      highlightedTitle: 'Offline',
      description:
          'Read and write messages offline. Everything syncs automatically '
          'when you reconnect.',
      imagePath: AssetPaths.illustration2,
    ),
    IntroductionModel(
      title: 'Private and',
      highlightedTitle: 'Secure',
      description:
          'Your conversations stay protected, so you can chat with confidence.',
      imagePath: AssetPaths.illustration3,
    ),
  ];

  bool get _isLastPage => _currentPage == _introductionPages.length - 1;

  void _goToNextPage() {
    if (_isLastPage) {
      _goToSignInScreen();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _skipIntroduction() {
    _pageController.animateToPage(
      _introductionPages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goToSignInScreen() {
    Navigator.pushReplacementNamed(context, SignInScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSkipButton(),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _introductionPages.length,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return IntroductionPage(
                    introduction: _introductionPages[index],
                  );
                },
              ),
            ),

            _buildPageIndicator(),
            const SizedBox(height: 32),
            _buildNextButton(),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLastPage
                  ? _buildExistingAccountButton()
                  : const SizedBox(height: 48),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerRight,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: _isLastPage ? 0 : 1,
            child: TextButton(
              onPressed: _isLastPage ? null : _skipIntroduction,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return SmoothPageIndicator(
      controller: _pageController,
      count: _introductionPages.length,
      onDotClicked: (int index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
      effect: const ExpandingDotsEffect(
        dotWidth: 9,
        dotHeight: 9,
        spacing: 7,
        expansionFactor: 3,
        activeDotColor: AppColors.primary,
        dotColor: AppColors.iconPrimary,
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: _goToNextPage,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _isLastPage ? 'Get Started' : 'Next',
              key: ValueKey<bool>(_isLastPage),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExistingAccountButton() {
    return SizedBox(
      height: 48,
      key: const ValueKey<String>('existing-account'),
      child: TextButton(
        onPressed: _goToSignInScreen,
        child: const Text(
          'I already have an account',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
