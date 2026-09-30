const subscriptionService = require('./subscriptionService');

class PaymentService {
  constructor() {
    this.apiKey = process.env.DIGIPAY_API_KEY || '';
    this.appId = process.env.DIGIPAY_APP_ID || '';
    let rawBase = process.env.DIGIPAY_BASE_URL || 'https://digitalcertify.tech/v1/api';
    rawBase = rawBase.replace(/\/+$/, '');
    if (rawBase === 'https://digitalcertify.tech') {
      rawBase = 'https://digitalcertify.tech/v1/api';
    }
    this.baseUrl = rawBase;
  }

  /**
   * Process a payment using DigiPay API (Mobile Money / Card)
   */
  async processPayment({ userId, planId, amount, phoneNumber, operator, email, paymentMethod, cardDetails }) {
    const reference = `DIGIPAY_SPK_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
    let cleanPhone = (phoneNumber || '').replace(/[^0-9]/g, '');
    
    // In Cameroon, Mobile Money numbers are 9 digits (e.g., 6XXXXXXXX) -> international format is 2376XXXXXXXX
    if (cleanPhone.length === 9) {
      cleanPhone = `237${cleanPhone}`;
    }
    const cleanOperator = (operator || 'MTN').toUpperCase();

    console.log(`[DigiPay Service] Initiating payment for User: ${userId}, Plan: ${planId}, Amount: ${amount} FCFA, Phone: ${cleanPhone}, Operator: ${cleanOperator}`);

    // If live DigiPay API key is configured in .env, call the live DigiPay gateway
    if (this.apiKey && this.apiKey !== 'your_digipay_api_key_here') {
      try {
        const payload = {
          amount: Number(amount),
          customerPhone: cleanPhone,
          metadata: {
            orderId: reference,
            userId: userId,
            planId: planId,
            operator: cleanOperator
          }
        };

        const response = await fetch(`${this.baseUrl}/payments/initiate`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': this.apiKey
          },
          body: JSON.stringify(payload)
        });

        const data = await response.json();
        console.log('[DigiPay Gateway Response]:', data);

        if (!response.ok || data.success === false) {
          const errorMsg = (typeof data.message === 'object' ? JSON.stringify(data.message) : data.message) || 'DigiPay payment initiation failed';
          throw new Error(errorMsg);
        }

        const txnInfo = data.data || data;
        const transactionId = txnInfo.transactionId || txnInfo.transaction_id || txnInfo.id || reference;
        const txnStatus = (txnInfo.status || 'COMPLETED').toUpperCase();

        // On successful initiation or approval, upgrade user plan in database
        const subResult = await subscriptionService.subscribeUser(userId, planId);

        return {
          success: true,
          reference: reference,
          transactionId: transactionId,
          freemopayReference: txnInfo.freemopayReference || null,
          status: txnStatus,
          message: txnInfo.message || `DigiPay payment of ${amount} FCFA processed successfully. Your account is upgraded!`,
          plan: subResult.plan
        };
      } catch (apiError) {
        console.error('[DigiPay API Gateway Error]:', apiError.message);
        throw new Error(`DigiPay Gateway Error: ${apiError.message}`);
      }
    } else {
      // Sandbox / Test simulation mode when API key is not yet added
      console.log('[DigiPay Notice] Running in DigiPay Sandbox Mode (Add DIGIPAY_API_KEY to backend/.env for live billing)');
      
      // Simulate gateway processing delay
      await new Promise(resolve => setTimeout(resolve, 800));

      const subResult = await subscriptionService.subscribeUser(userId, planId);

      return {
        success: true,
        reference: reference,
        transactionId: `SANDBOX_${reference}`,
        status: 'COMPLETED',
        message: `DigiPay Sandbox: Payment of ${amount} FCFA approved. Upgraded to ${subResult.plan.name}!`,
        plan: subResult.plan
      };
    }
  }

  /**
   * Verify a DigiPay transaction status by reference / transactionId
   */
  async verifyPayment(reference) {
    if (!this.apiKey || this.apiKey === 'your_digipay_api_key_here') {
      return { success: true, status: 'COMPLETED', reference };
    }

    try {
      const response = await fetch(`${this.baseUrl}/payments/transactions/${reference}`, {
        headers: {
          'x-api-key': this.apiKey
        }
      });
      const resData = await response.json();
      if (resData.success && resData.data) {
        return {
          success: true,
          status: (resData.data.status || 'COMPLETED').toUpperCase(),
          transactionId: resData.data.transactionId,
          amount: resData.data.totalAmount || resData.data.amount,
          phone: resData.data.customerPhone,
          createdAt: resData.data.createdAt,
          data: resData.data
        };
      }
      return resData;
    } catch (err) {
      console.error('[DigiPay Verify Error]:', err.message);
      return { success: false, error: err.message };
    }
  }
}

module.exports = new PaymentService();

