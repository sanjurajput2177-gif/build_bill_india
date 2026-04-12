import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import '../models/models.dart';

class CashfreeService {
  final cfPaymentGatewayService = CFPaymentGatewayService();

  // Note: Order creation should ideally happen on the backend to keep Secret Key safe.
  // This service handles the SDK checkout flow.
  
  Future<void> startCheckout({
    required CompanyProfile profile,
    required String orderId,
    required String paymentSessionId,
    required Function(String) onVerify,
    required Function(String) onError,
  }) async {
    try {
      var session = CFSessionBuilder()
          .setEnvironment(CFEnvironment.SANDBOX) // Change to PRODUCTION when ready
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      var cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
          .setSession(session)
          .build();

      cfPaymentGatewayService.setCallback(
        (String orderId) {
          onVerify(orderId);
        },
        (CFErrorResponse errorResponse, String orderId) {
          onError(errorResponse.getMessage() ?? "Payment failed");
        },
      );

      await cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
    } catch (e) {
      onError(e.toString());
    }
  }
}
