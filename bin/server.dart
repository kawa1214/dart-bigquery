import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:dart_bigquery/clients/big_query_client.dart';

void main() async {
  final handler = Pipeline().addHandler(_queryRequest);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

Future<Response> _queryRequest(Request request) async {
  final client = await BigQueryClient.getInstance();

  final res = await client.query('''
    select * from table
    ''');

  final errors = res.errors ?? [];
  if (errors.isNotEmpty) {
    throw Exception(errors);
  }

  final tableRows = res.rows;
  if (tableRows == null) {
    throw Exception('Incorrect query');
  }

  final data = tableRows.map((e) => e.f!.map((e) => e.toJson())).toList();

  return Response.ok(data);
}
