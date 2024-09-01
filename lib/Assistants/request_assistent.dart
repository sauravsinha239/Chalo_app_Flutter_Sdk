import 'dart:convert';
import 'package:http/http.dart' as http;
class RequestAssistant{
  static Future<dynamic>receiveRequest(String url)async{

    http.Response httpResponse = await http.get(Uri.parse(url));
    try {
      if (httpResponse.statusCode == 200) { // sucessfull
        String responseData = httpResponse.body; //json
        var decodeResponseData = jsonDecode(responseData);
        return decodeResponseData;
      }
      else{
        return "error Occured : Failed. no Response";
      }
    }
    catch(exp){
      return "error Occured : Failed. no Response";
    }

    
  }
}