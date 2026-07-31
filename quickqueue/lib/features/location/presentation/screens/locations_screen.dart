import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../queue/presentation/screens/services_screens.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/usecases/get_current_position.dart';
import '../../domain/usecases/get_locations.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key, required this.category});

  final LocationCategory category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocationBloc(
        getLocations: sl<GetLocations>(),
        getCurrentPosition: sl<GetCurrentPosition>(),
        category: category,
      )..add(const LocationsRequested()),
      child: _LocationsView(category: category),
    );
  }
}

class _LocationsView extends StatelessWidget {
  const _LocationsView({required this.category});

  final LocationCategory category;

  String get _categoryLabel => category == LocationCategory.hospital ? 'Hospitals' : 'Banks';

  String get _headerSubtitle =>
      category == LocationCategory.hospital ? 'Select a hospital to join' : 'Select a bank to join';

  Future<void> _openDirections(BuildContext context, LocationEntity location) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
    );
    var opened = false;
    try {
      // webOnlyWindowName forces a new browser tab on web instead of
      // navigating the current one away from the app — without it some
      // browsers fall back to replacing the current page when a popup is
      // blocked, which looks like the app itself broke.
      opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open maps — check your connection and try again")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          QQHeader(
            title: _categoryLabel,
            subtitle: _headerSubtitle,
          ),
          Expanded(
            child: BlocConsumer<LocationBloc, LocationState>(
              listenWhen: (previous, current) =>
                  previous.locateErrorMessage != current.locateErrorMessage &&
                  current.locateErrorMessage != null,
              listener: (context, state) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.locateErrorMessage!)));
              },
              builder: (context, state) {
                if (state.status == LocationStatus.loading || state.status == LocationStatus.initial) {
                  return Center(child: CircularProgressIndicator(color: colors.primary));
                }
                if (state.status == LocationStatus.error) {
                  return Center(child: Text(state.errorMessage ?? 'Something went wrong'));
                }

                final locations = state.filteredLocations;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back, size: 16, color: colors.primary),
                              const SizedBox(width: 6),
                              Text(AppStrings.backToCategories, style: AppStyles.link(context)),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Welcome User',
                              style: AppStyles.sectionTitle(context).copyWith(color: colors.primary),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: state.locatingUser
                                ? null
                                : () => context
                                    .read<LocationBloc>()
                                    .add(const UseCurrentLocationRequested()),
                            icon: state.locatingUser
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(
                                    state.userPosition == null
                                        ? Icons.my_location
                                        : Icons.location_on,
                                    size: 16,
                                  ),
                            label: Text(
                              state.userPosition == null ? 'Use my location' : 'Nearest first',
                              style: AppStyles.link(context).copyWith(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
                          ),
                        ],
                      ),
                      Text(
                        "Don't know exactly where a place is? Use your location or tap the pin to get directions.",
                        style: AppStyles.caption(context),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        onChanged: (value) =>
                            context.read<LocationBloc>().add(LocationSearchChanged(value)),
                        style: AppStyles.body(context),
                        decoration: InputDecoration(
                          hintText: AppStrings.searchForPlace,
                          hintStyle: AppStyles.body(context).copyWith(color: colors.textMuted),
                          prefixIcon: Icon(Icons.search, color: colors.textMuted),
                          filled: true,
                          fillColor: colors.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: locations.isEmpty
                            ? Center(child: Text('No locations found', style: AppStyles.bodyMuted(context)))
                            : ListView.separated(
                                itemCount: locations.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final location = locations[index];
                                  final isSelected = state.selected?.id == location.id;
                                  return _LocationCard(
                                    location: location,
                                    isSelected: isSelected,
                                    distanceKm: state.distanceKm(location),
                                    onTap: () => context.read<LocationBloc>().add(LocationSelected(location)),
                                    onDirections: () => _openDirections(context, location),
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
  const _LocationCard({
    required this.location,
    required this.isSelected,
    required this.onTap,
    required this.onDirections,
    this.distanceKm,
  });

  final LocationEntity location;
  final bool isSelected;
  final double? distanceKm;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = Color(location.colorValue);
    return Material(
      color: isSelected ? colors.primaryLight : colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? colors.primary : Colors.transparent, width: 1.4),
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
                  style: AppStyles.cardTitle(context).copyWith(color: accent),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location.name, style: AppStyles.cardTitle(context)),
                    const SizedBox(height: 2),
                    Text(
                      distanceKm == null
                          ? '${location.area}, ${location.district}'
                          : '${location.area}, ${location.district} · ${distanceKm!.toStringAsFixed(1)} km away',
                      style: AppStyles.bodyMuted(context),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDirections,
                tooltip: 'Get directions',
                icon: Icon(Icons.directions_outlined, color: colors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
