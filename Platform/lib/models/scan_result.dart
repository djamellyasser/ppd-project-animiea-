enum AnemiaStatus { anemic, notAnemic }

extension AnemiaStatusExtension on AnemiaStatus {
  String get label {
    switch (this) {
      case AnemiaStatus.anemic:
        return 'Anemic';
      case AnemiaStatus.notAnemic:
        return 'Not Anemic';
    }
  }
}

class ScanResult {
  final AnemiaStatus status;
  final DateTime scannedAt;
  final String scanMethod;
  final double confidence;

  const ScanResult({
    required this.status,
    required this.scannedAt,
    required this.scanMethod,
    this.confidence = 0.0,
  });

  factory ScanResult.mock() => ScanResult(
        status: AnemiaStatus.anemic,
        scannedAt: DateTime.now(),
        scanMethod: 'eyelid',
        confidence: 0.87,
      );
}

class UserProfile {
  final String name;
  final int age;
  final double weight;

  const UserProfile({
    required this.name,
    required this.age,
    required this.weight,
  });

  factory UserProfile.mock() => const UserProfile(
        name: 'Yassine A.',
        age: 24,
        weight: 72,
      );
}