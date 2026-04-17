import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits true when the device has any network connection (wifi / mobile / ethernet / vpn).
/// Emits false when there is no connectivity.
///
/// This only checks the radio — not actual internet reachability. Good enough
/// to gate UI messages like "Connect to internet to take the quiz".
final connectivityStreamProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  final initial = await connectivity.checkConnectivity();
  yield _hasConnection(initial);

  yield* connectivity.onConnectivityChanged.map(_hasConnection);
});

/// Synchronous snapshot. Returns true if currently online (best effort — defaults
/// to online during the brief moment before the stream emits its first value).
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityStreamProvider).maybeWhen(
        data: (online) => online,
        orElse: () => true,
      );
});

bool _hasConnection(List<ConnectivityResult> results) {
  return results.any((r) => r != ConnectivityResult.none);
}
