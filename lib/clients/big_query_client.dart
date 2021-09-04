import 'dart:io';

import 'package:googleapis/bigquery/v2.dart' as googleapis;
import 'package:googleapis_auth/auth_io.dart' as googleapis_auth;
import 'package:googleapis_auth/googleapis_auth.dart' as googleapis_auth;

import '../constants/environment_variables.dart' as environment_variables;

class BigQueryClient {
  BigQueryClient(this.projectId, this.authClient);

  final String projectId;
  final googleapis_auth.AutoRefreshingAuthClient authClient;

  Future<googleapis.QueryResponse> query(String query) async {
    try {
      final queryResponse = await googleapis.BigqueryApi(authClient).jobs.query(
            googleapis.QueryRequest(
              useLegacySql: false,
              query: query,
              timeoutMs: 50000,
            ),
            projectId,
          );
      return queryResponse;
    } catch (e, s) {
      stderr.writeAll({
        'Error': e,
        'StackTrace': s,
      }.entries);
      rethrow;
    }
  }

  static Future<BigQueryClient> getInstance() async {
    final env = Platform.environment;

    final credentials = googleapis_auth.ServiceAccountCredentials.fromJson({
      'type': 'service_account',
      'project_id': env[environment_variables.projectIdMapKey],
      'private_key_id': env[environment_variables.privateKeyIdMapKey],
      'private_key':
          '-----BEGIN PRIVATE KEY-----\n${env[environment_variables.privateKeyMapKey]}\n-----END PRIVATE KEY-----\n',
      'client_email': env[environment_variables.clientEmailMapKey],
      'client_id': env[environment_variables.clientIdMapKey],
    });

    final authClient = await googleapis_auth.clientViaServiceAccount(
      credentials,
      [googleapis.BigqueryApi.bigqueryScope],
    );
    return BigQueryClient(
      env[environment_variables.projectIdMapKey]!,
      authClient,
    );
  }
}
