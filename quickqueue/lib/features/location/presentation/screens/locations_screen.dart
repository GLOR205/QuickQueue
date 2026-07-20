import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../queue/presentation/screens/services_screens.dart';
import '../../data/datasources/location_remote_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/usecases/get_locations.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = LocationRepositoryImpl(MockLocationRemoteDataSource());
        return LocationBloc(getLocations: GetLocations(repository))
          ..add(const LocationsRequested());
      },
      child: const _LocationsView(),
    );
  }
}

class _LocationsView extends StatelessWidget {
  const _LocationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const QQHeader(
            title: AppStrings.whereAreYouGoing,
            subtitle: AppStrings.selectLocationSubtitle,
          ),
          Expanded(
            child: BlocBuilder<LocationBloc, LocationState>(
              builder: (context, state) {
                if (state.status == LocationStatus.loading || state.status == LocationStatus.initial) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (state.status == LocationStatus.error) {
                  return Center(child: Text(state.errorMessage ?? 'Something went wrong'));
                }

                final locations = state.filteredLocations;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome User', style: AppStyles.sectionTitle.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 14),
                      TextField(
                        onChanged: (value) =>
                            context.read<LocationBloc>().add(LocationSearchChanged(value)),
                        style: AppStyles.body,
                        decoration: InputDecoration(
                          hintText: AppStrings.searchForPlace,
                          hintStyle: AppStyles.body.copyWith(color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: locations.isEmpty
                            ? Center(child: Text('No locations found', style: AppStyles.bodyMuted))
                            : ListView.separated(
                                itemCount: locations.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final location = locations[index];
                                  final isSelected = state.selected?.id == location.id;
                                  return _LocationCard(
                                    location: location,
                                    isSelected: isSelected,
                                    onTap: () => context.read<LocationBloc>().add(LocationSelected(location)),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 12),
                      QQButton(
                        label: AppStrings.continueLabel,
                        onPressed: state.selected == null
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ServicesScreen(location: state.selected!),
                                  ),
                                ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location, required this.isSelected, required this.onTap});

  final LocationEntity location;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Color(location.colorValue);
    return Material(
      color: isSelected ? AppColors.primaryLight : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 1.4),
            boxShadow: isSelected
                ? null
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  location.avatarLetter,
                  style: AppStyles.cardTitle.copyWith(color: accent),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location.name, style: AppStyles.cardTitle),
                    const SizedBox(height: 2),
                    Text('${location.area}, ${location.district}', style: AppStyles.bodyMuted),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
