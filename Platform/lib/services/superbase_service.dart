import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  String? get _uid => _client.auth.currentUser?.id;

  // ── USER ──
  Future<void> createUser({
    required String name,
    required int age,
    required double weight,
  }) async {
    if (_uid == null) return;
    await _client.from('users').insert({
      'id': _uid,
      'name': name,
      'age': age,
      'weight': weight,
      'scan_count': 0,
    });
  }

  Future<Map<String, dynamic>?> getUser() async {
    if (_uid == null) return null;
    final response =
        await _client.from('users').select().eq('id', _uid!).maybeSingle();
    return response;
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    if (_uid == null) return;
    await _client.from('users').update(data).eq('id', _uid!);
  }

  // ── SCANS ──
  Future<void> saveScan(String status, double confidence) async {
    if (_uid == null) return;
    await _client.from('scans').insert({
      'user_id': _uid,
      'status': status,
      'confidence': confidence,
      'scan_method': 'eyelid',
    });
    // Increment scan count
    final user = await getUser();
    if (user != null) {
      await _client.from('users').update({
        'scan_count': (user['scan_count'] ?? 0) + 1,
      }).eq('id', _uid!);
    }
  }

  Stream<List<Map<String, dynamic>>> scansStream() {
    return _client
        .from('scans')
        .stream(primaryKey: ['id'])
        .eq('user_id', _uid ?? '')
        .order('scanned_at', ascending: false)
        .map((data) => data);
  }

  Future<Map<String, dynamic>?> getLastScan() async {
    if (_uid == null) return null;
    final response = await _client
        .from('scans')
        .select()
        .eq('user_id', _uid!)
        .order('scanned_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return response;
  }
}
