import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bloc/auth/admin_auth_bloc.dart';
import '../../widgets/admin_drawer.dart';
import '../../widgets/stats_card.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          BlocBuilder<AdminAuthBloc, AdminAuthState>(
            builder: (context, state) {
              if (state is AdminAuthAuthenticated) {
                return PopupMenuButton(
                  icon: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      state.admin.displayName.isNotEmpty 
                        ? state.admin.displayName[0].toUpperCase()
                        : 'A',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(state.admin.displayName),
                        subtitle: Text(state.admin.email),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      child: const ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('تسجيل الخروج'),
                      ),
                      onTap: () {
                        context.read<AdminAuthBloc>().add(AdminSignOut());
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: AdminDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            BlocBuilder<AdminAuthBloc, AdminAuthState>(
              builder: (context, state) {
                if (state is AdminAuthAuthenticated) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              state.admin.displayName.isNotEmpty 
                                ? state.admin.displayName[0].toUpperCase()
                                : 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
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
                                  'مرحباً، ${state.admin.displayName}',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'مرحباً بك في لوحة التحكم',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            const SizedBox(height: 24),
            
            // Stats Cards
            Text(
              'الإحصائيات',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                StatsCard(
                  title: 'إجمالي المستخدمين',
                  value: '1,234',
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap: () => Navigator.of(context).pushNamed('/users'),
                ),
                StatsCard(
                  title: 'الأقسام',
                  value: '12',
                  icon: Icons.category,
                  color: Colors.green,
                  onTap: () => Navigator.of(context).pushNamed('/categories'),
                ),
                StatsCard(
                  title: 'المقاطع الصوتية',
                  value: '456',
                  icon: Icons.music_note,
                  color: Colors.orange,
                  onTap: () => Navigator.of(context).pushNamed('/tracks'),
                ),
                StatsCard(
                  title: 'المشتركين',
                  value: '89',
                  icon: Icons.star,
                  color: Colors.purple,
                  onTap: () => Navigator.of(context).pushNamed('/users'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Charts Section
            Text(
              'التحليلات',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            
            const SizedBox(height: 16),
            
            // User Growth Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نمو المستخدمين',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو'];
                                  if (value.toInt() < months.length) {
                                    return Text(
                                      months[value.toInt()],
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                const FlSpot(0, 100),
                                const FlSpot(1, 150),
                                const FlSpot(2, 200),
                                const FlSpot(3, 300),
                                const FlSpot(4, 450),
                                const FlSpot(5, 600),
                              ],
                              isCurved: true,
                              color: Theme.of(context).primaryColor,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Subscription Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'توزيع الاشتراكات',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: 60,
                              title: 'مجاني\n60%',
                              color: Colors.grey,
                              radius: 80,
                            ),
                            PieChartSectionData(
                              value: 20,
                              title: 'شهري\n20%',
                              color: Colors.blue,
                              radius: 80,
                            ),
                            PieChartSectionData(
                              value: 15,
                              title: 'سنوي\n15%',
                              color: Colors.green,
                              radius: 80,
                            ),
                            PieChartSectionData(
                              value: 5,
                              title: 'أسبوعي\n5%',
                              color: Colors.orange,
                              radius: 80,
                            ),
                          ],
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Quick Actions
            Text(
              'إجراءات سريعة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/categories'),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة قسم'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/tracks'),
                    icon: const Icon(Icons.music_note),
                    label: const Text('إضافة مقطع'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
