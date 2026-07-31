import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up_with_email.dart';
import '../../features/location/data/datasources/device_location_datasource.dart';
import '../../features/location/data/datasources/location_remote_datasource.dart';
import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/domain/usecases/get_current_position.dart';
import '../../features/location/domain/usecases/get_locations.dart';
import '../../features/queue/data/datasources/queue_remote_datasource.dart';
import '../../features/queue/data/repositories/queue_repository_impl.dart';
import '../../features/queue/domain/repositories/queue_repository.dart';
import '../../features/queue/domain/usecases/get_notifications.dart';
import '../../features/queue/domain/usecases/get_queue_position.dart';
import '../../features/queue/domain/usecases/get_queues.dart';
import '../../features/queue/domain/usecases/join_queue.dart';
import '../../features/queue/domain/usecases/leave_queue.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/change_password.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/submit_rating.dart';
import '../../features/profile/domain/usecases/update_preferences.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/staff/data/datasources/staff_remote_datasource.dart';
import '../../features/staff/data/repositories/staff_repository_impl.dart';
import '../../features/staff/domain/repositories/staff_repository.dart';
import '../../features/staff/domain/usecases/get_queue_ticket_history.dart';
import '../../features/staff/domain/usecases/get_queue_tickets.dart';
import '../../features/staff/domain/usecases/get_staff_queue_options.dart';
import '../../features/staff/domain/usecases/mark_served.dart';
import '../../features/staff/domain/usecases/sign_in_staff.dart';
import '../../features/staff/domain/usecases/sign_out_staff.dart';
import '../../features/staff/domain/usecases/sign_up_staff.dart';
import '../../features/staff/domain/usecases/skip_patient.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSource(
      auth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  // Location
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => FirebaseLocationRemoteDataSource(firestore: sl()),
  );
  sl.registerLazySingleton<DeviceLocationDataSource>(
    () => GeolocatorDeviceLocationDataSource(),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetLocations(sl()));
  sl.registerLazySingleton(() => GetCurrentPosition(sl()));

  // Queue
  sl.registerLazySingleton<QueueRemoteDataSource>(
    () => FirebaseQueueRemoteDataSource(firestore: sl(), auth: sl()),
  );
  sl.registerLazySingleton<QueueRepository>(
    () => QueueRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetQueues(sl()));
  sl.registerLazySingleton(() => JoinQueue(sl()));
  sl.registerLazySingleton(() => GetQueuePosition(sl()));
  sl.registerLazySingleton(() => LeaveQueue(sl()));
  sl.registerLazySingleton(() => GetNotifications(sl()));

  // Profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => FirebaseProfileRemoteDataSource(auth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => SubmitRating(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton(() => UpdatePreferences(sl()));

  // Staff
  sl.registerLazySingleton<StaffRemoteDataSource>(
    () => FirebaseStaffRemoteDataSource(auth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SignInStaff(sl()));
  sl.registerLazySingleton(() => SignUpStaff(sl()));
  sl.registerLazySingleton(() => SignOutStaff(sl()));
  sl.registerLazySingleton(() => GetStaffQueueOptions(sl()));
  sl.registerLazySingleton(() => GetQueueTickets(sl()));
  sl.registerLazySingleton(() => GetQueueTicketHistory(sl()));
  sl.registerLazySingleton(() => MarkServed(sl()));
  sl.registerLazySingleton(() => SkipPatient(sl()));
}
