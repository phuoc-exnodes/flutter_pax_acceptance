<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them. 

## Features


Pair PAX Terminal
Connect PAX's Websocket Server
Process Sale Request
Process Refund Request



## Getting started

Prepare a PAX Terminal which is configured to the Store merchant, Installed Acceptance device app

## Usage

These steps is for newly connection between POS device and PAX terminal;

Step 1:
Instantiating FlutterPaxAcceptance class and call init() on it. 
This will check device's storage for required files like rootCA, Private certificate and PAX's Host string.
If  already having those files, FlutterPaxAcceptance will automatically connect to PAX's socket server
```dart
  final FlutterPaxAcceptance _paxAcceptance = FlutterPaxAcceptance();
    _paxAcceptance.initialize(
      onGetRootCA:(){
        //Callback to provide rootCA when no local rootCA is founded
      }
    );
```

If state is notReady, then add PAX Terminal Server rootCA

```dart
    final String rootCA = yourRootCASource();
    _paxAcceptance.setRootCA(rootCA);
```
Or setting callback for getting rootCA 

```dart
     final FlutterPaxAcceptance _paxAcceptance = FlutterPaxAcceptance();
    _paxAcceptance.onGetRootCA = rootCAsource();
    //Call refresh to apply changes
    _paxAcceptance.refresh();
```

Step 2:
Pair the POS device and PAX Terminal by calling this function:

posId : A String of only numbers.
ipAddress: PAX terminal IpAddress.
port: PAX terminal Port.
setupCode: Code from PAX\'s Pair screen.

```dart
   paxAcceptance.pairPAXTerminal(
                            ipAddress: '192.168.x.x',
                              port:8443,
                            posId: 'Your POSID number',
                            setupCode: 'Code from PAX\'s Pair screen');
```
If Pair success, a Private certificate (String) are received and stored, also save the Host used.

Step 3: 
Connect to the PAX Terminal Websocket Server by calling connect() on the FlutterPaxAcceptance class.
This method will setup a HttpClient with a SecureContext which is configured to use the rootCA,  Certificate chain from Step 1 and 2.

```dart
    _paxAcceptance.connect();
```

If connect success, you can start sending request to Pax Terminal to process Sale and Refund.
You can use predefined class PayzliPaymentPAX passed in an instance of FlutterPaxAcceptance for a capsulated code. Or calling process() on FlutterPaxAcceptance for a customizable request.

Using predefined class PayzliPaymentPAX;

Processing a Sale request:

```dart
 final PayzliPaymentPAX payzliPaymentPAX = PayzliPaymentPAX(_paxAcceptance);
    final SalePaymentRequest request = SalePaymentRequest(
      merchantReferenceCode: 'your customer id',
      amountDetails: const AmountDetails.sale(currency: 'USD', amount: '1.00'),
    );

    payzliPaymentPAX.transactionSale(
      request,
      onDoneApproved: (response) {
        //Process success payment response
      },
      onDoneAborted: (response) {
        //Process Aborted payment response
      },
      onError: (error) {
        //Process Error
      },
      onErrorResponse: (response) {
        //Process Error payment response
      },
      onStatus: (response) {
        //Process Pax terminal Status in mid-transaction
      },
    );
```
Using pure request using process() method on  FlutterPaxAcceptance();

IMPORTANT: Call completeProcessing() to release the processing state after the transaction. Otherwise, calling process() again wont work

```dart
  final Map<String, dynamic> request = {
      'type': 'ProcessSale',
      'merchantReferenceCode': 'custom ID',
      'amountDetails': {
        'currency':'USD',
        'amount':'1.00',
      },
    };
   
    _paxAcceptance.process( 
      request
    , (data) { 
        ///Handle reponse from PAX terminal: PaymentResponse,ErrorResponse,...
    });

      ///Call completeProcessing() to set the FlutterPaxAcceptance state back to 'connected' to be able to process later request.
    _paxAcceptance.completeProcessing();
```




## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
