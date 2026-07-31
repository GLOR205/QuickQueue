import '../repositories/profile_repository.dart';

class SubmitRating {
  const SubmitRating(this._repository);

  final ProfileRepository _repository;

  Future<void> call({
    required int stars,
    required String comment,
    required String serviceName,
  }) {
    return _repository.submitRating(stars: stars, comment: comment, serviceName: serviceName);
  }
}
