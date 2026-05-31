package com.smusix.app.activitesfragments.premium

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingFlowParams.ProductDetailsParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.ConsumeParams
import com.android.billingclient.api.ConsumeResponseListener
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import com.google.gson.Gson
import com.smusix.app.Constants
import com.smusix.app.R
import com.smusix.app.activitesfragments.accounts.AccountUtils
import com.smusix.app.activitesfragments.accounts.AccountUtils.getUserModel
import com.smusix.app.activitesfragments.profile.videopromotion.VideoPromoteStepsA
import com.smusix.app.apiclasses.ApiLinks
import com.smusix.app.databinding.ActivityPurchasePremiumBinding
import com.smusix.app.models.SubscriptionModel
import com.smusix.app.simpleclasses.Functions
import com.smusix.app.simpleclasses.Variables
import com.volley.plus.VPackages.VolleyRequest
import org.json.JSONObject

class PurchasePremiumActivity : AppCompatActivity(), PurchasesUpdatedListener {

    lateinit var binding: ActivityPurchasePremiumBinding
    var walletType = "wallet"
    var googleType = "googleplay"
    var type = walletType
    var walletAmount = 0.0
    var purchaseID = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding=ActivityPurchasePremiumBinding.inflate(layoutInflater)
        setContentView(binding.root)


        initalizeBill()

        binding.backBtn.setOnClickListener{
            finish()
        }



        inits()
        binding.walletCard.setOnClickListener {
            if (walletAmount > 0){
                type = walletType
                updateUi()
            }else{
                Functions.showToast(this, getString(R.string.you_don_t_have_enough_funds))
            }

        }
        binding.googleCard.setOnClickListener {
            type = googleType
            updateUi()
        }
        binding.payBtn.setOnClickListener {
            if (type == walletType ){
                if (walletAmount >= Constants.SUBSCRIPTION_PRICE.toDouble()){
                    callApiPurchaseSubscription()
                }else{
                    Functions.showToast(this,getString(R.string.you_don_t_have_enough_funds))
                }
            }else if(type == googleType){
                purchaseItem()
            }

        }

    }


    fun callApiPurchaseSubscription() {
        val parameters = JSONObject()
        try {
            parameters.put("user_id",Functions.getSharedPreference(this).getString(Variables.U_ID,"") )
            parameters.put("purchase_from",type )
            parameters.put("amount",Constants.SUBSCRIPTION_PRICE )
            if(type.equals(walletType)){
                val coinWorth = Functions.getSettingsPreference(this).getString(Variables.CoinWorth, "0")!!.toDouble()
                val coin = maxOf(1, (Constants.SUBSCRIPTION_PRICE.toDouble() / coinWorth).toInt())
                parameters.put("coin",""+coin)
            }
            else{
                parameters.put("coin",0)
            }
            parameters.put("transaction_id",purchaseID )
        } catch (e: Exception) {
            e.printStackTrace()
        }
        VolleyRequest.JsonPostRequest(
            this, ApiLinks.purchaseSubscription, parameters, Functions.getHeaders(this)
        ) { resp ->
            Functions.checkStatus(this, resp)
            try {
                val response = JSONObject(resp)
                val code = response.optString("code")
                if (code == "200") {
                    val msg=response.optJSONObject("msg")
                    val subscription=msg.optJSONObject("Subscription")

                    val subscriptionModel= Gson().fromJson(subscription.toString(), SubscriptionModel::class.java)
                    val userModel= AccountUtils.getUserModel(Functions.getSharedPreference(this).getString(Variables.U_ID,"")!!)
                    userModel?.subscriptionModel=subscriptionModel
                    AccountUtils.updateUserModel(userModel!!)

                    Functions.showAlert(this@PurchasePremiumActivity,getString(R.string.premium),
                        getString(R.string.purchase_completed_successfully_enjoy_all_the_benefits_of_smusix_premium),
                        getString(R.string.promote_video),
                        getString(R.string.cancel_),{
                            if(it.equals("yes")){
                                startActivity(Intent(this, VideoPromoteStepsA::class.java))
                            }
                            finish()
                        })

                } else {
                    Log.d(Constants.tag,response.optString("msg"))
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    fun inits(){
        var smix = Functions.getSharedPreference(this).getString(Variables.U_WALLET, "0")
        walletAmount = Functions.getWalletFromSmix(this,smix)
        Log.d(Constants.tag, "inits: $walletAmount")
        if (walletAmount > 0){
            type  = walletType
            updateUi()
        }else{
            type = googleType
            updateUi()
        }
        binding.walletTv.text = "$walletAmount ${Constants.DefaultCurrency}"
    }

    fun updateUi(){
        if (type ==  walletType) {
            binding.selectLay1.visibility = View.VISIBLE
            binding.selectLay2.visibility = View.GONE
        }else{
            binding.selectLay1.visibility = View.GONE
            binding.selectLay2.visibility = View.VISIBLE
        }
    }


    var billingClient: BillingClient? = null
    var inAppProductList: ArrayList<ProductDetails> = ArrayList()

    fun initalizeBill() {
        billingClient = BillingClient.newBuilder(this@PurchasePremiumActivity)
            .setListener(this)
            .enablePendingPurchases()
            .build()
        startBillingConnection()
    }

    private fun startBillingConnection() {
        billingClient!!.startConnection(object : BillingClientStateListener {
            override fun onBillingServiceDisconnected() {
                Log.d(Constants.tag, "Not Connected Connect Again")
                startBillingConnection()
            }

            override fun onBillingSetupFinished(billingResult: BillingResult) {
                Log.d(Constants.tag, "startConnection: " + billingResult.responseCode)
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    InitPurchases()
                    this@PurchasePremiumActivity.previousPurchaseDetails
                }
            }
        })
    }


    val previousPurchaseDetails: Unit
        get() {
            val queryPurchasesParams =
                QueryPurchasesParams.newBuilder().setProductType(BillingClient.ProductType.INAPP)
                    .build()
            billingClient!!.queryPurchasesAsync(queryPurchasesParams) { billingResult, list ->
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    for (purchase in list) {
                        consumeItem(purchase)
                    }
                }
            }
        }

    override fun onPurchasesUpdated(billingResult: BillingResult, purchases: List<Purchase>?) {
        if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && purchases != null) {
            for (purchase in purchases) {
                this@PurchasePremiumActivity.runOnUiThread { handlePurchase(purchase) }
            }
        } else if (billingResult.responseCode == BillingClient.BillingResponseCode.USER_CANCELED) {
            Log.d(Constants.tag, "" + billingResult.responseCode + "--" + BillingClient.BillingResponseCode.USER_CANCELED)
        } else {
            Log.d(Constants.tag, "" + billingResult.responseCode)
        }
    }

    private fun handlePurchase(purchase: Purchase) {
        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
            if (!purchase.isAcknowledged) {
                val acknowledgePurchaseParams = AcknowledgePurchaseParams.newBuilder()
                    .setPurchaseToken(purchase.purchaseToken)

                billingClient!!.acknowledgePurchase(acknowledgePurchaseParams.build()) { billingResult ->
                    if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                        Log.d(Constants.tag, "Billing : Call API Fo Success " + purchase.originalJson)
                        consumeItem(purchase)
                        purchaseID = purchase.purchaseToken
                        callApiPurchaseSubscription()
                    } else {
                        Log.d(Constants.tag, "ResponseCode : " + billingResult.responseCode)
                    }
                }
            }
        }
    }


    fun consumeItem(purchase: Purchase) {
        val consumeParams = ConsumeParams.newBuilder().setPurchaseToken(purchase.purchaseToken).build()
        billingClient!!.consumeAsync(consumeParams, object : ConsumeResponseListener {
            override fun onConsumeResponse(p0: BillingResult, p1: String) {
                TODO("Not yet implemented")
            }
        })
    }


    // when we click the continue btn this method will call
    fun purchaseItem() {
        Log.d(Constants.tag, "inAppProductList Size: " + inAppProductList.size)
        val productDetailsParamsList: MutableList<ProductDetailsParams> = ArrayList()

        for (item in inAppProductList) {
            var offerToken:String?=null
            item.subscriptionOfferDetails?.forEach { offer ->
                val basePlanId = offer.basePlanId
                if(basePlanId.equals("artist-monthly-plan")) {
                    offerToken = offer.offerToken
                }
            }

            if(offerToken!=null) {
                productDetailsParamsList.add(
                    ProductDetailsParams.newBuilder()
                        .setProductDetails(item)
                        .setOfferToken(offerToken!!)
                        .build()
                )
            }else{
                productDetailsParamsList.add(
                    ProductDetailsParams.newBuilder()
                        .setProductDetails(item)
                        .build()
                )
            }

        }
        if(productDetailsParamsList.isNotEmpty()) {
            val billingFlowParams = BillingFlowParams.newBuilder()
                .setProductDetailsParamsList(productDetailsParamsList)
                .build()
            billingClient!!.launchBillingFlow(this, billingFlowParams)
        }
    }


    private fun InitPurchases() {
        val queryProductDetailsParams = QueryProductDetailsParams
            .newBuilder()
            .setProductList(getInAppProduct())
        billingClient!!.queryProductDetailsAsync(queryProductDetailsParams.build()) { billingResult, productDetailsList ->
            Log.d(Constants.tag, "queryProductDetailsAsync: " + billingResult.responseCode)
            if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                populateRegisterInAppProducts(productDetailsList)
            }
        }
    }

    private fun populateRegisterInAppProducts(productDetailsList: List<ProductDetails>) {
        Log.d(Constants.tag, "populateRegisterInAppProducts: $productDetailsList")
        inAppProductList.clear()
        for (item in productDetailsList) {
            Log.d(Constants.tag, "productDetails: " + item.productId)
            inAppProductList.add(item)
        }
    }

    private fun getInAppProduct():List<QueryProductDetailsParams.Product>{
        val productList: MutableList<QueryProductDetailsParams.Product> = ArrayList()
        productList.add(
            QueryProductDetailsParams
                .Product.newBuilder()
                .setProductId(Constants.SUBSCRIPTION_ID)
                .setProductType(BillingClient.ProductType.SUBS)
                .build()
        )
        return productList
    }

    override fun onDestroy() {
        billingClient!!.endConnection()
        super.onDestroy()
    }


}