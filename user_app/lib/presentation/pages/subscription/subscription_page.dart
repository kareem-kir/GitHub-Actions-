import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/user/user_bloc.dart';
import '../../../shared/models/user_model.dart';

class SubscriptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاشتراك'),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserLoaded) {
            return _buildSubscriptionContent(context, state.user);
          } else if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(RefreshUserData());
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionContent(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current Subscription Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    _getSubscriptionIcon(user.status),
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'اشتراكك الحالي',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getSubscriptionText(user.status),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (user.subscriptionExpiry != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      user.isSubscriptionActive
                        ? 'ينتهي في: ${_formatDate(user.subscriptionExpiry!)}'
                        : 'انتهى في: ${_formatDate(user.subscriptionExpiry!)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: user.isSubscriptionActive 
                          ? Theme.of(context).textTheme.bodyMedium?.color
                          : Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Subscription Plans
          Text(
            'خطط الاشتراك',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          
          const SizedBox(height: 16),
          
          // Free Plan
          _buildPlanCard(
            context,
            title: 'مجاني',
            price: '0 ريال',
            features: [
              'الوصول للمحتوى المجاني',
              'جودة صوت عادية',
              'إعلانات',
            ],
            isCurrentPlan: user.status == SubscriptionStatus.free,
            isRecommended: false,
          ),
          
          const SizedBox(height: 12),
          
          // Weekly Plan
          _buildPlanCard(
            context,
            title: 'أسبوعي',
            price: '15 ريال',
            features: [
              'الوصول لجميع المحتوى',
              'جودة صوت عالية',
              'بدون إعلانات',
              'تحميل غير محدود',
            ],
            isCurrentPlan: user.status == SubscriptionStatus.weekly,
            isRecommended: false,
          ),
          
          const SizedBox(height: 12),
          
          // Monthly Plan
          _buildPlanCard(
            context,
            title: 'شهري',
            price: '50 ريال',
            features: [
              'الوصول لجميع المحتوى',
              'جودة صوت عالية',
              'بدون إعلانات',
              'تحميل غير محدود',
              'محتوى حصري',
            ],
            isCurrentPlan: user.status == SubscriptionStatus.monthly,
            isRecommended: true,
          ),
          
          const SizedBox(height: 12),
          
          // Yearly Plan
          _buildPlanCard(
            context,
            title: 'سنوي',
            price: '500 ريال',
            subtitle: 'وفر 100 ريال',
            features: [
              'الوصول لجميع المحتوى',
              'جودة صوت عالية',
              'بدون إعلانات',
              'تحميل غير محدود',
              'محتوى حصري',
              'دعم أولوية',
            ],
            isCurrentPlan: user.status == SubscriptionStatus.yearly,
            isRecommended: false,
          ),
          
          const SizedBox(height: 32),
          
          // Contact for Upgrade
          Card(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.phone,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'للترقية أو تجديد الاشتراك',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تواصل معنا عبر الواتساب وسيتم تفعيل اشتراكك فوراً',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _contactWhatsApp(context),
                    icon: const Icon(Icons.message),
                    label: const Text('تواصل عبر الواتساب'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    String? subtitle,
    required List<String> features,
    required bool isCurrentPlan,
    required bool isRecommended,
  }) {
    return Card(
      elevation: isRecommended ? 8 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isRecommended
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'الأفضل',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )).toList(),
              
              if (isCurrentPlan) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'الخطة الحالية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSubscriptionIcon(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return Icons.person;
      case SubscriptionStatus.weekly:
        return Icons.star;
      case SubscriptionStatus.monthly:
        return Icons.star_border;
      case SubscriptionStatus.yearly:
        return Icons.workspace_premium;
    }
  }

  String _getSubscriptionText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return 'مجاني';
      case SubscriptionStatus.weekly:
        return 'أسبوعي';
      case SubscriptionStatus.monthly:
        return 'شهري';
      case SubscriptionStatus.yearly:
        return 'سنوي';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _contactWhatsApp(BuildContext context) async {
    const phoneNumber = '+966501234567'; // Replace with actual WhatsApp number
    const message = 'مرحباً، أريد الاستفسار عن خطط الاشتراك في مشغل الموسيقى';
    
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح الواتساب'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ في فتح الواتساب'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
