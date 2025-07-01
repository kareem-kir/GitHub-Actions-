import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/users/users_bloc.dart';
import '../../../shared/models/user_model.dart';

class UserDetailsDialog extends StatefulWidget {
  final UserModel user;
  final bool editMode;

  const UserDetailsDialog({
    Key? key,
    required this.user,
    this.editMode = false,
  }) : super(key: key);

  @override
  _UserDetailsDialogState createState() => _UserDetailsDialogState();
}

class _UserDetailsDialogState extends State<UserDetailsDialog> {
  SubscriptionStatus? _selectedStatus;
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.user.status;
    _selectedExpiryDate = widget.user.subscriptionExpiry;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is UsersSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.user.displayName.isNotEmpty 
                        ? widget.user.displayName[0].toUpperCase()
                        : 'م',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.editMode ? 'تعديل اشتراك المستخدم' : 'تفاصيل المستخدم',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          widget.user.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // User Information
              if (!widget.editMode) ...[
                _buildInfoCard(),
                const SizedBox(height: 16),
                _buildSubscriptionCard(),
                const SizedBox(height: 16),
                _buildStatsCard(),
              ] else ...[
                _buildEditSubscriptionForm(),
              ],
              
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إغلاق'),
                  ),
                  if (widget.editMode) ...[
                    const SizedBox(width: 16),
                    BlocBuilder<UsersBloc, UsersState>(
                      builder: (context, state) {
                        final isLoading = state is UsersLoading;
                        
                        return ElevatedButton(
                          onPressed: isLoading ? null : _updateSubscription,
                          child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('تحديث'),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المعلومات الأساسية',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('الاسم', widget.user.displayName),
            _buildInfoRow('رقم الهاتف', widget.user.phone),
            _buildInfoRow('البريد الإلكتروني', widget.user.email ?? 'غير محدد'),
            _buildInfoRow('معرف المستخدم', widget.user.id),
            _buildInfoRow('تاريخ التسجيل', _formatDate(widget.user.createdAt)),
            _buildInfoRow('آخر نشاط', _formatDate(widget.user.lastActive)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الاشتراك',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getSubscriptionColor(widget.user.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getSubscriptionText(widget.user.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (!widget.user.isSubscriptionActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'منتهي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.user.subscriptionExpiry != null)
              _buildInfoRow(
                'تاريخ الانتهاء',
                _formatDate(widget.user.subscriptionExpiry!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإحصائيات',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('إجمالي التحميلات', widget.user.totalDownloads.toString()),
            _buildInfoRow('المقاطع المحملة', widget.user.downloadedTracks.length.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildEditSubscriptionForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تعديل الاشتراك',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Subscription Type
            DropdownButtonFormField<SubscriptionStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'نوع الاشتراك',
              ),
              items: SubscriptionStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getSubscriptionText(status)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                  if (value == SubscriptionStatus.free) {
                    _selectedExpiryDate = null;
                  } else if (_selectedExpiryDate == null) {
                    // Set default expiry date based on subscription type
                    final now = DateTime.now();
                    switch (value!) {
                      case SubscriptionStatus.weekly:
                        _selectedExpiryDate = now.add(const Duration(days: 7));
                        break;
                      case SubscriptionStatus.monthly:
                        _selectedExpiryDate = DateTime(now.year, now.month + 1, now.day);
                        break;
                      case SubscriptionStatus.yearly:
                        _selectedExpiryDate = DateTime(now.year + 1, now.month, now.day);
                        break;
                      default:
                        break;
                    }
                  }
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Expiry Date
            if (_selectedStatus != SubscriptionStatus.free) ...[
              InkWell(
                onTap: _selectExpiryDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاريخ انتهاء الاشتراك',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedExpiryDate != null
                      ? _formatDate(_selectedExpiryDate!)
                      : 'اختر التاريخ',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubscriptionColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return Colors.grey;
      case SubscriptionStatus.weekly:
        return Colors.orange;
      case SubscriptionStatus.monthly:
        return Colors.blue;
      case SubscriptionStatus.yearly:
        return Colors.green;
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

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() {
        _selectedExpiryDate = date;
      });
    }
  }

  void _updateSubscription() {
    if (_selectedStatus == null) return;

    context.read<UsersBloc>().add(
      UpdateUserSubscription(
        widget.user.id,
        _selectedStatus!,
        expiryDate: _selectedExpiryDate,
      ),
    );
  }
}
