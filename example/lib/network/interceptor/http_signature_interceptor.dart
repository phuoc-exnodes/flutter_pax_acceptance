import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../evironment.dart';

///https://developer.cybersource.com/docs/cybs/en-us/platform/developer/all/rest/rest-getting-started/restgs-http-message-intro/restgs-http-message-conf-intro.html
class HttpSignatureInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    const merchantId = EvironmentDev.merchantId;
    const key = EvironmentDev.key;
    const sharedSecret = EvironmentDev.sharedSecret;
    // final date = 'Thu, 10 Oct 2024 08:59:26 GMT';
    final date = HttpDate.format(DateTime.now());
    final host = options.uri.host;

    //Required headers
    final headers = {
      "v-c-merchant-id": merchantId,
      "Date": date,
      "Content-Type": 'application/json',
      "Host": host
    };
    options.headers.remove('content-type');
    options.headers.addAll(headers);

    try {
      //Generate a Hash of the Message Body And  add to Digest header field
      final bodyHashDigest =
          'SHA-256=${generateDigest(jsonEncode(options.data))}';

      //Generate the Signature Hash
// Follow these steps to generate the signature hash value:
// Generate a byte array of the secret key generated previously. For more information, see Create a Shared Secret Key Pair.
// Generate the HMAC SHA-256 key object using the byte array of the secret key.
// Concatenate a string of the required information listed above.
// For more information, see Creating the Validation String below.
// Generate a byte array of the validation string.
// Use the HMAC SHA-256 key object to create the HMAC SHA-256 hash of the validation string byte array.
// Base64 encode the HMAC SHA-256 hash.
      var headerHash = {
        'host': host,
        'date': date,
        'request-target': '${options.method.toLowerCase()} ${options.uri.path}',
        'v-c-merchant-id': merchantId,
      };
      if (options.method.toLowerCase() != 'get' &&
          options.method.toLowerCase() != 'delete') {
        options.headers.addAll({'Digest': bodyHashDigest});
        headerHash.addAll({'digest': bodyHashDigest});
      }

      String validationString = '';
      headerHash.forEach(
        (key, value) {
          if (validationString != '') {
            validationString += '\n';
          }
          validationString += key.toLowerCase() + ": " + value;
        },
      );
      final hashString = generateSignatureFromParams(
        validationString,
        sharedSecret,
      );

      final signHeader = {
        'Signature':
            'keyid="$key", algorithm="HmacSHA256", headers="${headerHash.keys.toList().join(' ')}", signature="$hashString"'
      };
      options.headers.addAll(signHeader);
    } catch (e) {
      print(e);
    }

    super.onRequest(options, handler);
  }

  //testest to generate the same as in POSTMANT
  String generateDigest(String bodyText) {
    final bytes = utf8.encode(bodyText);
    final digest = sha256.convert(bytes);
    final base64Digest = base64Encode(digest.bytes);
    return base64Digest;
  }

  //testest to generate the same as in POSTMANT
  String generateSignatureFromParams(String signatureParams, String secretKey) {
    final words = base64Decode(secretKey);
    final sigBytes = utf8.encode(signatureParams);

    final messageHash = Hmac(sha256, words).convert(sigBytes);

    final base64Hash = base64Encode(messageHash.bytes);
    return base64Hash;
  }
}
