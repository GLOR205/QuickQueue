import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/profile/presentation/bloc/profile_event.dart';
import '../../features/profile/presentation/screens/user_profile_screen.dart';
import '../../features/queue/presentation/bloc/queue_bloc.dart';
import '../../features/queue/presentation/bloc/queue_event.dart';
import '../../features/queue/presentation/screens/my_ticket_screen.dart';
import '../../features/queue/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../widgets/app_bottom_nav.dart';
import 'nav_tab_cubit.dart';

/// The app's persistent home: a single Scaffold with a bottom nav bar over
/// an [IndexedStack] of the Ticket/Alerts/Profile tabs. Switching tabs never
/// pushes or pops a route, so none of the three lose their state and none
/// of them can strand the user without a way back — the bug that made
/// tapping between screens sometimes leave no path back to the ticket.
///
/// Locations/Services stay regular pushed routes reached from the empty
/// Ticket tab's "Find a queue" button, then pop back to this shell once a
/// queue is joined.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  @override
  void initState() {
    super.initState();
    context.read<QueueBloc>().add(const NotificationsRequested());
    context.read<ProfileBloc>().add(const ProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavTabCubit, QQNavTab>(
      builder: (context, tab) {
        return Scaffold(
          body: IndexedStack(
            index: tab.index,
            children: const [
              MyTicketBody(),
              NotificationsBody(),
              ProfileBody(),
            ],
          ),
          bottomNavigationBar: QQBottomNav(
            current: tab,
            onTabSelected: (t) => context.read<NavTabCubit>().select(t),
          ),
        );
      },
    );
  }
}
