import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/app_bottom_nav.dart';

/// Which shell tab is active. Session-scoped so screens outside the shell
/// (e.g. Services, after joining a queue) can select a tab before popping
/// back to it.
class NavTabCubit extends Cubit<QQNavTab> {
  NavTabCubit() : super(QQNavTab.ticket);

  void select(QQNavTab tab) => emit(tab);
}
