package com.smusix.app.activitesfragments.premium

import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.text.Spannable
import android.text.SpannableString
import android.text.Spanned
import android.text.TextPaint
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import android.text.style.ForegroundColorSpan
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.RelativeLayout
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingFlowParams.ProductDetailsParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.google.gson.Gson
import com.smusix.app.Constants
import com.smusix.app.R
import com.smusix.app.activitesfragments.WebviewA
import com.smusix.app.activitesfragments.accounts.AccountUtils
import com.smusix.app.activitesfragments.accounts.AccountUtils.getUserModel
import com.smusix.app.apiclasses.ApiLinks
import com.smusix.app.databinding.FragmentPremiumBinding
import com.smusix.app.models.SubscriptionModel
import com.smusix.app.simpleclasses.Functions
import com.smusix.app.simpleclasses.Variables
import com.volley.plus.VPackages.VolleyRequest
import org.json.JSONObject


class PremiumF : Fragment(), PurchasesUpdatedListener {
    lateinit var binding : FragmentPremiumBinding


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // Inflate the layout for this fragment
        binding =  FragmentPremiumBinding.inflate(layoutInflater, container, false)

        val from=requireArguments().getString("from","viewPager")
        if(!from.equals("viewPager")){
            binding.btnCross.visibility=View.VISIBLE
            val layoutParams = binding.mainLayout.layoutParams as RelativeLayout.LayoutParams
            layoutParams.setMargins(30, 120, 30, 120)
            binding.mainLayout.layoutParams = layoutParams
            binding.mainLayout.radius= (Functions.convertDpToPx(requireContext(),20)).toFloat()
        }

        inits()

        checkButtonStatus()
        binding.purchaseBtn.setOnClickListener{
           initalizeBill()
        }

        binding.btnCross.setOnClickListener{
            requireActivity().supportFragmentManager.popBackStack()
        }

        return binding.root
    }


    fun checkButtonStatus(){
        if(Functions.checkPremium(requireContext())){
            binding.purchaseBtn.isEnabled=false
            binding.purchaseBtn.setText(this.getString(R.string.you_already_premium))
        }else{
            binding.purchaseBtn.isEnabled=true
            val userModel = getUserModel(Functions.getSharedPreference(requireContext()).getString(Variables.U_ID, "")!!)
            if (userModel?.subscriptionModel != null) {
                binding.purchaseBtn.setText(getString(R.string.re_subscribe))
            }
            else{
                binding.purchaseBtn.setText(getString(R.string.try_it_for_free))
            }

        }
    }

    fun inits(){

        Functions.printLog(Constants.tag,"SUBSCRIPTION_PRICE:"+Constants.SUBSCRIPTION_PRICE)

        setTrailText()

        val fullText = getString(R.string.by_continue_you_accept_the_terms_and_conditions)
        val termsAndConditionsText = getString(R.string.terms_and_conditions)
        val spannableString = SpannableString(fullText)

        val startIndex = fullText.indexOf(termsAndConditionsText)
        val endIndex = startIndex + termsAndConditionsText.length

        if (startIndex != -1) {
            // Set a clickable span
            val clickableSpan = object : ClickableSpan() {
                override fun onClick(widget: View) {
                    val countryCode = Functions.getSettingsPreference(context).getString(
                        Variables.AppLevelLanguageCode,
                        Variables.DEFAULT_LANGUAGE_CODE)
                    if (countryCode.equals("de",false)){
                        openWebUrl(getString(R.string.term_condition_title), Constants.privacyPolicyGerman)
                    }else if (countryCode.equals("es",false)){
                        openWebUrl(getString(R.string.term_condition_title), Constants.privacyPolicySpanish)
                    }else if (countryCode.equals("fr",false)){
                        openWebUrl(getString(R.string.term_condition_title), Constants.privacyPolicyFranch)
                    }else if (countryCode.equals("it",false)){
                        openWebUrl(getString(R.string.term_condition_title), Constants.privacyPolicyItalian)
                    }else if (countryCode.equals("pt",false)){
                        openWebUrl(getString(R.string.term_condition_title), Constants.privacyPolicyPortuguese)
                    }else{
                        openWebUrl(getString(R.string.term_condition_title), Constants.privacyPolicyEng)
                    }
                }

                override fun updateDrawState(ds: TextPaint) {
                    super.updateDrawState(ds)
                    ds.isUnderlineText = false
                    ds.color = ContextCompat.getColor(context!!, android.R.color.white)
                }
            }
            spannableString.setSpan(clickableSpan, startIndex, endIndex, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        }

        binding.termConditionText.text = spannableString
        binding.termConditionText.movementMethod = LinkMovementMethod.getInstance()
    }

    fun setTrailText(){
        val priceTxt = Functions.getSettingsPreference(context)
            .getString(Variables.Currency, Constants.DefaultCurrency) + " " +
                Functions.getLocalPrice(context, Constants.SUBSCRIPTION_PRICE, false)+"/${getString(R.string.month)}"

        val subscriptionTxt=getString(R.string.subscription)
        val fullText = getString(R.string.premium_des1,priceTxt)+getString(R.string.premium_des2)+getString(R.string.premium_des3)+" "+subscriptionTxt+"."

        Functions.printLog(Constants.tag,fullText)
        val spannableString = SpannableString(fullText)

        val startIndex = fullText.indexOf(priceTxt)
        val endIndex = startIndex + priceTxt.length
        spannableString.setSpan(ForegroundColorSpan(Color.RED), startIndex, endIndex, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)

 /*       val subscriptionStart = fullText.indexOf(subscriptionTxt)
        val subscriptionEnd = subscriptionStart + subscriptionTxt.length
        val clickableSpan = object : ClickableSpan() {
            override fun onClick(widget: View) {
                val intent = Intent(Intent.ACTION_VIEW)
                intent.setData(Uri.parse("https://play.google.com/store/account/subscriptions"))
                intent.setPackage("com.android.vending") // Ensures it opens in Play Store
                startActivity(intent)

            }

            override fun updateDrawState(ds: TextPaint) {
                super.updateDrawState(ds)
                ds.isUnderlineText = true
                ds.color = ContextCompat.getColor(context!!, R.color.appColor)
            }
        }

        spannableString.setSpan(
            clickableSpan,
            subscriptionStart,
            subscriptionEnd,
            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
        )
*/
        binding.decPremium.text = spannableString
        binding.decPremium.movementMethod = LinkMovementMethod.getInstance()

    }

    fun openWebUrl(title: String?, url: String?) {
        val intent = Intent(context, WebviewA::class.java)
        intent.putExtra("url", url)
        intent.putExtra("title", title)
        startActivity(intent)
        activity?.overridePendingTransition(R.anim.in_from_right, R.anim.out_to_left)


    }

    var billingClient: BillingClient? = null
    var inAppProductList: ArrayList<ProductDetails> = ArrayList()
    var purchaseID = ""
    fun initalizeBill() {
        billingClient = BillingClient.newBuilder(requireActivity())
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
                }
            }
        })

    }

    override fun onPurchasesUpdated(billingResult: BillingResult, purchases: List<Purchase>?) {
        if (billingResult.responseCode == BillingClient.BillingResponseCode.OK && purchases != null) {
            for (purchase in purchases) {
                requireActivity().runOnUiThread { handlePurchase(purchase) }
            }
        }
        else if (billingResult.responseCode == BillingClient.BillingResponseCode.USER_CANCELED) {
            Log.d(Constants.tag, "" + billingResult.responseCode + "--" + BillingClient.BillingResponseCode.USER_CANCELED)
        }
        else {
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
                       purchaseID = purchase.purchaseToken
                        callApiPurchaseSubscription()
                    } else {
                        Log.d(Constants.tag, "ResponseCode : " + billingResult.responseCode)
                    }
                }

            }
        }

    }

    // when we click the continue btn this method will call
    fun purchaseItem() {
        Log.d(Constants.tag, "inAppProductList: " + inAppProductList.size)
        var productDetailsParamsList: MutableList<ProductDetailsParams> = ArrayList()
        for (item in inAppProductList) {
            if (item.getSubscriptionOfferDetails()!!.isNotEmpty()) {

                var offerToken:String?=null
                item.subscriptionOfferDetails?.forEach { offer ->
                    val basePlanId = offer.basePlanId
                    if(basePlanId.equals("my30")) {
                        offerToken = offer.offerToken
                    }
                }
                Functions.printLog(Constants.tag, "offerToken:" + offerToken)

                if(offerToken!=null) {
                    productDetailsParamsList.add(
                        ProductDetailsParams.newBuilder()
                            .setProductDetails(item)
                            .setOfferToken(offerToken)
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

        }
        Functions.printLog(Constants.tag,"productDetailsParamsList:"+productDetailsParamsList.size)
        if(productDetailsParamsList.isNotEmpty()) {
            Functions.printLog(Constants.tag,"launchBillingFlow")

            val billingFlowParams = BillingFlowParams.newBuilder()
                .setProductDetailsParamsList(productDetailsParamsList)
                .build()
            billingClient!!.launchBillingFlow(requireActivity(), billingFlowParams)

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
                    purchaseItem()


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

    fun callApiPurchaseSubscription() {
        val parameters = JSONObject()
        try {
            parameters.put("user_id",Functions.getSharedPreference(requireContext()).getString(Variables.U_ID,"") )
            parameters.put("purchase_from","googleplay" )
            parameters.put("amount",Constants.SUBSCRIPTION_PRICE )
            parameters.put("transaction_id",purchaseID )
            parameters.put("coin",0)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        VolleyRequest.JsonPostRequest(
            requireActivity(), ApiLinks.purchaseSubscription, parameters, Functions.getHeaders(requireContext())
        ) { resp ->
            try {
                val response = JSONObject(resp)
                val code = response.optString("code")
                if (code == "200") {

                    val msg=response.optJSONObject("msg")
                    val subscription=msg.optJSONObject("Subscription")
                    val subscriptionModel= Gson().fromJson(subscription.toString(),
                        SubscriptionModel::class.java)
                    val userModel= AccountUtils.getUserModel(Functions.getSharedPreference(requireContext()).getString(Variables.U_ID,"")!!)
                    userModel?.subscriptionModel=subscriptionModel
                    AccountUtils.updateUserModel(userModel!!)

                    checkButtonStatus()
                    Functions.showAlert(requireActivity(),getString(R.string.premium),
                        getString(R.string.purchase_completed_successfully_enjoy_all_the_benefits_of_smusix_premium))

                } else {
                    Log.d(Constants.tag,response.optString("msg"))
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    override fun onDetach() {
        if(billingClient!=null) {
            billingClient!!.endConnection()
        }
        super.onDetach()
    }

    companion object {
        @JvmStatic
        fun newInstance(from:String) = PremiumF().apply {
                arguments = Bundle().apply {
                    putString("from", from)
                }
            }
    }

}