// // ignore: import_of_legacy_library_into_null_safe
// import 'package:dio/dio.dart';
// // ignore: import_of_legacy_library_into_null_safe
// import 'package:paystack_manager/models/api_response.dart';
// // ignore: import_of_legacy_library_into_null_safe
// import 'package:paystack_manager/models/payment_info.dart';
//
// class APIs {
//   static String chargeUrl = "https://api.paystack.co/charge";
//   static String submitPINUrl = "https://api.paystack.co/charge/submit_pin";
//   static String submitOTPUrl = "https://api.paystack.co/charge/submit_otp";
//   static String submitPhoneUrl = "https://api.paystack.co/charge/submit_phone";
//   static String verifyUrl = "https://api.paystack.co/transaction/verify/";
//   static String submitBirthDayUrl =
//       "https://api.paystack.co/charge/submit_birthday";
//   static String submitAddressUrl =
//       "https://api.paystack.co/charge/submit_address";
// }
//
// class PaystackPaymentApi {
//   //Innstance of dio class
//   static BaseOptions options = new BaseOptions(
//     connectTimeout: 30000,
//     receiveTimeout: 30000,
//   );
//   static Dio dio = new Dio(options);
//
//   static Future<APIResponse> chargeCard({
//     required PaymentInfo paymentInfo,
//   }) async {
//     APIResponse apiResponse;
//
//     //Preparing request payload
//     final Map<String, dynamic> formDataMap = {
//       "email": paymentInfo.email,
//       "amount": paymentInfo.amount,
//       "currency": paymentInfo.currency,
//       "reference": paymentInfo.reference,
//       "metadata": paymentInfo.metadata,
//       "card": {
//         "number": paymentInfo.paymentCard.number,
//         "cvv": paymentInfo.paymentCard.cvv,
//         "expiry_month": paymentInfo.paymentCard.month,
//         "expiry_year": paymentInfo.paymentCard.year
//       },
//     };
//
//     try {
//       var response = await dio.post(
//         APIs.chargeUrl,
//         data: formDataMap,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${paymentInfo.secretKey}',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         //format the response data for system to continue operating
//         apiResponse = APIResponse.fromObject(response.data);
//       } else {
//         var errorMessage = "Request Failed. Please try again later";
//
//         try {
//           //alert the user with the message from the server
//           errorMessage =
//               response.data["data"]["message"] ?? response.data["message"];
//         } catch (error) {
//           print("Error Data Getting Failed:: $error");
//         }
//
//         throw errorMessage;
//       }
//     } catch (error) {
//       DioError dioError = error as DioError;
//       var errorMessage = "Request Failed. Please try again later";
//
//       try {
//         //alert the user with the message from the server
//         // final jsonObject = convert.jsonDecode(error.message);
//         if (dioError.response.data["data"] != null) {
//           errorMessage = dioError.response.data["data"]["message"];
//         } else {
//           errorMessage = dioError.response.data["message"];
//         }
//       } catch (error) {
//         print("Error Data Getting Failed:: $error");
//       }
//
//       throw errorMessage;
//     }
//
//     return apiResponse;
//   }
//
//   static Future<APIResponse> sendPIN({
//     required PaymentInfo paymentInfo,
//     required String refrence,
//     required String pin,
//   }) async {
//     APIResponse apiResponse;
//
//     //Preparing request payload
//     final Map<String, dynamic> formDataMap = {
//       "pin": pin,
//       "reference": refrence,
//     };
//
//     try {
//       var response = await dio.post(
//         APIs.submitPINUrl,
//         data: formDataMap,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${paymentInfo.secretKey}',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         //format the response data for system to continue operating
//         apiResponse = APIResponse.fromObject(response.data);
//       } else {
//         var errorMessage = "Request Failed. Please try again later";
//
//         try {
//           //alert the user with the message from the server
//           if (response.data["data"] != null) {
//             errorMessage = response.data["data"]["message"];
//           } else {
//             errorMessage = response.data["message"];
//           }
//         } catch (error) {
//           print("Error Data Getting Failed:: $error");
//         }
//
//         throw errorMessage;
//       }
//     } catch (error) {
//       DioError dioError = error as DioError;
//       var errorMessage = "Request Failed. Please try again later";
//
//       try {
//         //alert the user with the message from the server
//         if (dioError.response?.data["data"] != null) {
//           errorMessage = dioError.response?.data["data"]["message"];
//         } else {
//           errorMessage = dioError.response.data["message"];
//         }
//       } catch (error) {
//         print("Error Data Getting Failed:: $error");
//       }
//
//       throw errorMessage;
//     }
//
//     return apiResponse;
//   }
//
//   static Future<APIResponse> sendOTP({
//     required String refrence,
//     required String otp,
//     required PaymentInfo paymentInfo,
//   }) async {
//     APIResponse apiResponse;
//
//     //Preparing request payload
//     final Map<String, dynamic> formDataMap = {
//       "otp": otp,
//       "reference": refrence,
//     };
//
//     try {
//       var response = await dio.post(
//         APIs.submitOTPUrl,
//         data: formDataMap,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${paymentInfo.secretKey}',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         //format the response data for system to continue operating
//         apiResponse = APIResponse.fromObject(response.data);
//       } else {
//         var errorMessage = "Request Failed. Please try again later";
//
//         try {
//           //alert the user with the message from the server
//           if (response.data["data"] != null) {
//             errorMessage = response.data["data"]["message"];
//           } else {
//             errorMessage = response.data["message"];
//           }
//         } catch (error) {
//           print("Error Data Getting Failed:: $error");
//         }
//
//         throw errorMessage;
//       }
//     } catch (error) {
//       DioError dioError = error as DioError;
//       var errorMessage = "Request Failed. Please try again later";
//
//       try {
//         //alert the user with the message from the server
//         if (dioError.response.data["data"] != null) {
//           errorMessage = dioError.response.data["data"]["message"];
//         } else {
//           errorMessage = dioError.response.data["message"];
//         }
//       } catch (error) {
//         print("Error Data Getting Failed:: $error");
//       }
//
//       throw errorMessage;
//     }
//
//     return apiResponse;
//   }
//
//   static Future<APIResponse> sendPhone({
//     required String refrence,
//     required PaymentInfo paymentInfo,
//     required String phone,
//   }) async {
//     APIResponse apiResponse;
//
//     //Preparing request payload
//     final Map<String, dynamic> formDataMap = {
//       "phone": phone,
//       "reference": refrence,
//     };
//
//     try {
//       var response = await dio.post(
//         APIs.submitPhoneUrl,
//         data: formDataMap,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${paymentInfo.secretKey}',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         //format the response data for system to continue operating
//         apiResponse = APIResponse.fromObject(response.data);
//       } else {
//         var errorMessage = "Request Failed. Please try again later";
//
//         try {
//           //alert the user with the message from the server
//           if (response.data["data"] != null) {
//             errorMessage = response.data["data"]["message"];
//           } else {
//             errorMessage = response.data["message"];
//           }
//         } catch (error) {
//           print("Error Data Getting Failed:: $error");
//         }
//
//         throw errorMessage;
//       }
//     } catch (error) {
//       DioError dioError = error as DioError;
//       var errorMessage = "Request Failed. Please try again later";
//
//       try {
//         //alert the user with the message from the server
//         if (dioError.response.data["data"] != null) {
//           errorMessage = dioError.response.data["data"]["message"];
//         } else {
//           errorMessage = dioError.response.data["message"];
//         }
//       } catch (error) {
//         print("Error Data Getting Failed:: $error");
//       }
//
//       throw errorMessage;
//     }
//
//     return apiResponse;
//   }
//
//   static Future<APIResponse> verifyTransaction({
//     required String refrence,
//     required PaymentInfo paymentInfo,
//   }) async {
//     APIResponse apiResponse;
//
//     try {
//       var response = await dio.get(
//         //for reading purpose
//         APIs.verifyUrl + "" + refrence,
//         options: Options(
//       F
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         //format the response data for system to continue operating
//         apiResponse = APIResponse.fromObject(response.data);
//       } else {
//         var errorMessage = "Request Failed. Please try again later";
//
//         try {
//           //alert the user with the message from the server
//           if (response.data["data"] != null) {
//             errorMessage = response.data["data"]["message"];
//           } else {
//             errorMessage = response.data["message"];
//           }
//         } catch (error) {
//           print("Error Data Getting Failed:: $error");
//         }
//
//         throw errorMessage;
//       }
//     } catch (error) {
//       DioError dioError = error as DioError;
//       var errorMessage = "Request Failed. Please try again later";
//
//       try {
//         //alert the user with the message from the server
//         if (dioError.response.data["data"] != null) {
//           errorMessage = dioError.response.data["data"]["message"];
//         } else {
//           errorMessage = dioError.response.data["message"];
//         }
//       } catch (error) {
//         print("Error Data Getting Failed:: $error");
//       }
//
//       throw errorMessage;
//     }
//
//     return apiResponse;
//   }
//
//   static Future<APIResponse> sendBirthday({
//     required String refrence,
//     required String dob,
//     required PaymentInfo paymentInfo,
//   }) async {
//     APIResponse apiResponse;
//
//     //Preparing request payload
//     final Map<String, dynamic> formDataMap = {
//       "birthday": dob,
//       "reference": refrence,
//     };
//
//     try {
//       var response = await dio.post(
//         APIs.submitBirthDayUrl,
//         data: formDataMap,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${paymentInfo.secretKey}',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         //format the response data for system to continue operating
//         apiResponse = APIResponse.fromObject(response.data);
//       } else {
//         var errorMessage = "Request Failed. Please try again later";
//
//         try {
//           //alert the user with the message from the server
//           if (response.data["data"] != null) {
//             errorMessage = response.data["data"]["message"];
//           } else {
//             errorMessage = response.data["message"];
//           }
//         } catch (error) {
//           print("Error Data Getting Failed:: $error");
//         }
//
//         throw errorMessage;
//       }
//     } catch (error) {
//       DioError dioError = error as DioError;
//       var errorMessage = "Request Failed. Please try again later";
//
//       try {
//         //alert the user with the message from the server
//         if (dioError.response.data["data"] != null) {
//           errorMessage = dioError.response.data["data"]["message"];
//         } else {
//           errorMessage = dioError.response.data["message"];
//         }
//       } catch (error) {
//         print("Error Data Getting Failed:: $error");
//       }
//
//       throw errorMessage;
//     }
//
//     return apiResponse;
//   }
//
//   static Future<APIResponse> sendAddress({
//     required String refrence,
//     required PaymentInfo paymentInfo,
//     required String address,
//     required String city,
//     required String state,
//     required String zipCode,
//   }) async {
//     APIResponse apiResponse;
//
//     //Preparing request payload
//     final Map<String, dynamic> formDataMap = {
//       "address": address,
//       "city": city,
//       "state": state,
//       "zipcode": zipCode,
//       "reference": refrence,
//     };
//
//     try {
//       var response = await dio.post(
//         APIs.submitAddressUrl,
//         data: formDataMap,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${paymentInfo.secretKey}',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         //format the response data for system to continue operating
//         apiResponse = APIResponse.fromObject(response.data);
//       } else {
//         var errorMessage = "Request Failed. Please try again later";
//
//         try {
//           //alert the user with the message from the server
//           if (response.data["data"] != null) {
//             errorMessage = response.data["data"]["message"];
//           } else {
//             errorMessage = response.data["message"];
//           }
//         } catch (error) {
//           print("Error Data Getting Failed:: $error");
//         }
//
//         throw errorMessage;
//       }
//     } catch (error) {
//       DioError dioError = error as DioError;
//       var errorMessage = "Request Failed. Please try again later";
//
//       try {
//         //alert the user with the message from the server
//         if (dioError.response.data["data"] != null) {
//           errorMessage = dioError.response.data["data"]["message"];
//         } else {
//           errorMessage = dioError.response.data["message"];
//         }
//       } catch (error) {
//         print("Error Data Getting Failed:: $error");
//       }
//
//       throw errorMessage;
//     }
//
//     return apiResponse;
//   }
//
//   static Future<APIResponse> mobileMoneyPayment({
//     required PaymentInfo paymentInfo,
//     required String provider,
//     required String phone,
//   }) async {
//     APIResponse apiResponse;
//
//     //Preparing request payload
//     final Map<String, dynamic> formDataMap = {
//       "email": paymentInfo.email,
//       "amount": paymentInfo.amount,
//       "currency": paymentInfo.currency,
//       "metadata": paymentInfo.metadata,
//       "reference": paymentInfo.reference,
//       "mobile_money": {
//         "phone": phone,
//         "provider": provider,
//       },
//     };
//
//     try {
//       var response = await dio.post(
//         APIs.chargeUrl,
//         data: formDataMap,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${paymentInfo.secretKey}',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         //format the response data for system to continue operating
//         apiResponse = APIResponse.fromObject(response.data);
//       } else {
//         var errorMessage = "Request Failed. Please try again later";
//
//         try {
//           //alert the user with the message from the server
//           if (response.data["data"] != null) {
//             errorMessage = response.data["data"]["message"];
//           } else {
//             errorMessage = response.data["message"];
//           }
//         } catch (error) {
//           print("Error Data Getting Failed:: $error");
//         }
//
//         throw errorMessage;
//       }
//     } catch (error) {
//       DioError dioError = error as DioError;
//       var errorMessage = "Request Failed. Please try again later";
//
//       try {
//         //alert the user with the message from the server
//         if (dioError.response.data["data"] != null) {
//           errorMessage = dioError.response.data["data"]["message"];
//         } else {
//           errorMessage = dioError.response.data["message"];
//         }
//       } catch (error) {
//         print("Error Data Getting Failed:: $error");
//       }
//
//       throw errorMessage;
//     }
//
//     return apiResponse;
//   }
//
//   static Future<APIResponse> bankPayment({
//     required String code,
//     required String accountNumber,
//     required PaymentInfo paymentInfo,
//   }) async {
//     APIResponse apiResponse;
//
//     //Preparing request payload
//     final Map<String, dynamic> formDataMap = {
//       "email": paymentInfo.email,
//       "amount": paymentInfo.amount,
//       "currency": paymentInfo.currency,
//       "metadata": paymentInfo.metadata,
//       "reference": paymentInfo.reference,
//       "bank": {
//         "code": code,
//         "account_number": accountNumber,
//       },
//     };
//
//     try {
//       var response = await dio.post(
//         APIs.chargeUrl,
//         data: formDataMap,
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${paymentInfo.secretKey}',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         //format the response data for system to continue operating
//         apiResponse = APIResponse.fromObject(response.data);
//       } else {
//         var errorMessage = "Request Failed. Please try again later";
//
//         try {
//           //alert the user with the message from the server
//           if (response.data["data"] != null) {
//             errorMessage = response.data["data"]["message"];
//           } else {
//             errorMessage = response.data["message"];
//           }
//         } catch (error) {
//           print("Error Data Getting Failed:: $error");
//         }
//
//         throw errorMessage;
//       }
//     } catch (error) {
//       DioError dioError = error as DioError;
//       var errorMessage = "Request Failed. Please try again later";
//
//       try {
//         //alert the user with the message from the server
//         if (dioError.response.data["data"] != null) {
//           errorMessage = dioError.response.data["data"]["message"];
//         } else {
//           errorMessage = dioError.response.data["message"];
//         }
//       } catch (error) {
//         print("Error Data Getting Failed:: $error");
//       }
//
//       throw errorMessage;
//     }
//
//     return apiResponse;
//   }
// }
//
// UI.Chat(
//         messages: [
//           ...chat.messages.map((e) => types.TextMessage(
//                 author: types.User(
//                   id: e.senderId.toString(),
//                   imageUrl: e.senderId == chat.id ? chat.avartar : null,
//                   firstName: e.senderId == chat.id ? chat.username : null,
//                 ),
//                 createdAt: DateTime.tryParse(e.time!)?.millisecondsSinceEpoch,
//                 remoteId: e.incomingId.toString(),
//                 text: e.content,
//                 id: e.id.toString(),
//                 status: e.status == ChatState.SNEDING
//                     ? types.Status.sending
//                     : e.status == ChatState.SENT
//                         ? types.Status.sent
//                         : e.status == ChatState.DELIVERED
//                             ? types.Status.delivered
//                             : e.status == ChatState.SEEN
//                                 ? types.Status.seen
//                                 : types.Status.error,
//               ))
//         ],
//         onSendPressed: (_) => sendMsg(_.text),
//         user: types.User(
//           id: '${userData.profile.id}',
//           imageUrl: userData.profile.avartar,
//           firstName: userData.profile.username,
//         ),
//         theme: UI.DefaultChatTheme(
//           primaryColor: Palette.primaryColor,
//           secondaryColor: Colors.grey.shade200,
//           messageBorderRadius: 10,
//           messageInsetsVertical: 7,
//           inputBackgroundColor: Colors.grey.shade200,
//           inputTextColor: context.textTheme.bodyText1?.color ?? Colors.black,
//           inputBorderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//         ),
//       )
