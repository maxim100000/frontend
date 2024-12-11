import 'dart:convert';

import 'package:http/http.dart' as http;

void main() async {
  http.Response resp = await http. put(
    Uri.http('127.0.0.1:8000', '/api/prophecy/13'),
    headers: {'Content-Type': 'application/json',
      'Authorization': 'Basic YWRtaW46YWRtaW4='},
    body: jsonEncode({"content": "смелым покоряются моря"}),
  );
  print(jsonDecode(utf8.decoder.convert(resp.bodyBytes)));
  //
  // http.Response resp2 = await http.post(
  //     Uri.http('127.0.0.1:8000', '/api/prophecy'),
  //     headers: {'Content-Type': 'application/json', 
  //     'Authorization': 'Basic YWRtaW46YWRtaW4=',
  //     //
  //     },
  //   body: jsonEncode({"content": "смелым покоряются моря"})
  //     );
  // print(jsonDecode(utf8.decoder.convert(resp.bodyBytes)));
  
  
}

