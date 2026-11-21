import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/core/network/http_client.dart';
import 'package:tiresense/features/sensors/data/datasources/sensor/mock/mock_http_client.dart';

final httpClientProvider = Provider<HttpClient>((ref) => MockHttpClient());
