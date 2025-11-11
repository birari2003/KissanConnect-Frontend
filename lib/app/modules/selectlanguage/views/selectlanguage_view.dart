import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/selectlanguage_controller.dart';

class SelectlanguageView extends GetView<SelectlanguageController> {
  SelectlanguageView({super.key}) {
    Get.put(SelectlanguageController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE8F5E9),
              const Color(0xFFFFF8E1),
              const Color(0xFFE0F2F1).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title with animation
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: const Text(
                          'Select Your Language',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'कृपया आपली भाषा निवडा | कृपया अपनी भाषा चुनें',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF388E3C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Language Selection Cards
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.languages.length,
                    itemBuilder: (context, index) {
                      final language = controller.languages[index];
                      return Obx(() {
                        final isSelected = controller.selectedLanguage.value == language;
                        final isSpeaking = controller.isSpeaking.value && isSelected;
                        
                        return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                              color: isSelected 
                                  ? Colors.white 
                                  : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: isSelected
                                  ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                                  : null,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: controller.isSpeaking.value
                                    ? null
                                    : () => controller.selectLanguage(language),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFE8F5E9)
                                              : Colors.grey[200],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            language.name[0],
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? const Color(0xFF2E7D32)
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              language.name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? const Color(0xFF2E7D32)
                                                    : Colors.grey[800],
                                              ),
                                            ),
                                            if (isSelected) ...[  
                                              const SizedBox(height: 4),
                                              Text(
                                                language.greeting,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.green[700],
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (isSpeaking)
                                        const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Color(0xFF4CAF50),
                                            ),
                                          ),
                                        )
                                      else if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF4CAF50),
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        ));
                          });
                        },
                      ),
                ),
                const SizedBox(height: 24),
                // Bottom decoration
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/images/smartshetkari.png'),
                      opacity: 0.1,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
