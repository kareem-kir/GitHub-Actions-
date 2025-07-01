import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../bloc/users/users_bloc.dart';
import '../../widgets/admin_drawer.dart';
import '../../../shared/models/user_model.dart';
import 'user_details_dialog.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                context.read<UsersBloc>().add(SearchUsers(_searchController.text));
              }
            },
            tooltip: 'تحديث',
          ),
        ],
      ),
      drawer: AdminDrawer(),
      body: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UsersSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh search results
            if (_searchController.text.isNotEmpty) {
              context.read<UsersBloc>().add(SearchUsers(_searchController.text));
            }
          } else if (state is UsersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Search Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'البحث عن المستخدمين',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                labelText: 'رقم الهاتف أو UID',
                                hintText: '+966xxxxxxxxx أو user_id',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onFieldSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  context.read<UsersBloc>().add(SearchUsers(value.trim()));
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_searchController.text.trim().isNotEmpty) {
                                context.read<UsersBloc>().add(SearchUsers(_searchController.text.trim()));
                              }
                            },
                            icon: const Icon(Icons.search),
                            label: const Text('بحث'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              context.read<UsersBloc>().add(SearchUsers(''));
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('مسح'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Users Table
            Expanded(
              child: BlocBuilder<UsersBloc, UsersState>(
                builder: (context, state) {
                  if (state is UsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UsersLoaded) {
                    if (state.searchQuery?.isEmpty ?? true) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'ابحث عن المستخدمين',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'استخدم رقم الهاتف أو UID للبحث',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (state.users.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off,
                              size: 64,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لم يتم العثور على مستخدمين',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'جرب البحث بكلمات مختلفة',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return Card(
                      margin: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'نتائج البحث (${state.users.length})',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Expanded(
                            child: DataTable2(
                              columnSpacing: 12,
                              horizontalMargin: 12,
                              minWidth: 900,
                              columns: const [
                                DataColumn2(
                                  label: Text('المستخدم'),
                                  size: ColumnSize.L,
                                ),
                                DataColumn2(
                                  label: Text('رقم الهاتف'),
                                  size: ColumnSize.M,
                                ),
                                DataColumn2(
                                  label: Text('الاشتراك'),
                                  size: ColumnSize.M,
                                ),
                                DataColumn2(
                                  label: Text('تاريخ الانتهاء'),
                                  size: ColumnSize.M,
                                ),
                                DataColumn2(
                                  label: Text('الإجراءات'),
                                  size: ColumnSize.M,
                                ),
                              ],
                              rows: state.users.map((user) {
                                return DataRow2(
                                  cells: [
                                    DataCell(
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            user.displayName,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            user.id,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(user.phone)),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getSubscriptionColor(user.status),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getSubscriptionText(user.status),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        user.subscriptionExpiry != null
                                          ? _formatDate(user.subscriptionExpiry!)
                                          : '-',
                                        style: TextStyle(
                                          color: user.isSubscriptionActive 
                                            ? null 
                                            : Colors.red,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility, size: 20),
                                            onPressed: () => _showUserDetails(context, user),
                                            tooltip: 'عرض التفاصيل',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () => _showEditSubscription(context, user),
                                            tooltip: 'تعديل الاشتراك',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is UsersError) {
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
                              if (_searchController.text.isNotEmpty) {
                                context.read<UsersBloc>().add(SearchUsers(_searchController.text));
                              }
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
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

  void _showUserDetails(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user),
    );
  }

  void _showEditSubscription(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user, editMode: true),
    );
  }
}
