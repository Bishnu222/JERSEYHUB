import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jerseyhub/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:jerseyhub/features/notification/presentation/widgets/notification_tile.dart';
import 'package:jerseyhub/app/shared_prefs/user_shared_prefs.dart';
import 'package:jerseyhub/app/service_locator/service_locator.dart';

class NotificationListView extends StatefulWidget {
  const NotificationListView({super.key});

  @override
  State<NotificationListView> createState() => _NotificationListViewState();
}

class _NotificationListViewState extends State<NotificationListView> {
  late final UserSharedPrefs _userSharedPrefs;

  @override
  void initState() {
    super.initState();
    _userSharedPrefs = serviceLocator<UserSharedPrefs>();
    _loadNotifications();
    _refreshNotificationsOnOpen();
  }

  void _refreshNotificationsOnOpen() {
    final userId = _userSharedPrefs.getCurrentUserId();
    if (userId != null && userId.isNotEmpty) {
      print(
        '🔍 NotificationListView: Refreshing notifications on page open for user: $userId',
      );
      // Add a small delay to ensure the bloc is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.read<NotificationBloc>().add(RefreshNotifications(userId));
        }
      });
    }
  }

  void _loadNotifications() {
    final userId = _userSharedPrefs.getCurrentUserId();
    print('🔍 NotificationListView: Current user ID: $userId');

    if (userId != null && userId.isNotEmpty) {
      print('🔍 NotificationListView: Loading notifications for user: $userId');
      try {
        context.read<NotificationBloc>().add(LoadNotifications(userId));
        context.read<NotificationBloc>().add(ConnectToSocket(userId));
        print('🔍 NotificationListView: Events dispatched successfully');
      } catch (e) {
        print('❌ NotificationListView: Error dispatching events: $e');
      }
    } else {
      print('❌ NotificationListView: No valid user ID found!');
      // Show a user-friendly message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to view notifications'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showClearAllConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Clear All Notifications',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to clear all notifications? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllNotifications();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  void _clearAllNotifications() {
    final userId = _userSharedPrefs.getCurrentUserId();
    if (userId != null) {
      context.read<NotificationBloc>().add(ClearAllNotifications(userId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications cleared!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded &&
                  state.notifications.isNotEmpty) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.unreadCount > 0)
                      TextButton(
                        onPressed: () {
                          final userId = _userSharedPrefs.getCurrentUserId();
                          if (userId != null) {
                            context.read<NotificationBloc>().add(
                              MarkAllAsRead(userId),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'All notifications marked as read!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Mark All Read',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    TextButton(
                      onPressed: () {
                        _showClearAllConfirmation(context);
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Retry loading notifications
                      _loadNotifications();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 18,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'ll see notifications here when they arrive',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            Theme.of(context).textTheme.bodyMedium?.color ??
                            Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadNotifications();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationTile(
                    notification: notification,
                    onTap: () {
                      // Handle notification tap
                      if (!notification.read) {
                        context.read<NotificationBloc>().add(
                          MarkAsRead(notification.id),
                        );
                      }
                    },
                    onMarkAsRead: () {
                      context.read<NotificationBloc>().add(
                        MarkAsRead(notification.id),
                      );
                    },
                  );
                },
              ),
            );
          }

          return Center(
            child: Text(
              'No notifications',
              style: TextStyle(
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
