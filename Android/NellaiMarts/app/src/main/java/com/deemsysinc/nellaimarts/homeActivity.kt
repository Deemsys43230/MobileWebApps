package com.deemsysinc.nellaimarts

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.net.Uri
import android.os.AsyncTask
import android.os.Build
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.preference.PreferenceManager
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import android.telephony.TelephonyManager
import android.util.Log
import android.view.View
import android.view.WindowManager
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.Toast
import com.deemsysinc.nellaimarts.Utils.ScanActivity
import com.deemsysinc.nellaimarts.Utils.utilityClass
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import kotlin.system.exitProcess

class homeActivity : AppCompatActivity() {

    lateinit var barcode: ImageView
    lateinit var call: ImageView
    lateinit var email: ImageView
    lateinit var share: ImageView
    lateinit var webview: WebView
//    lateinit var rateus: TextView
    lateinit var  progressBar: ProgressBar
    lateinit var  barcodeProgressBar: ProgressBar
    lateinit var sharedPreference: SharedPreferences
    private val ADD_TASK_REQUEST = 1
    lateinit  var statusUtility:utilityClass

    var isCameraPermissionEnabled:Boolean=false
    var isCallPermissionEnabled:Boolean=false
    lateinit var telephonyManager: TelephonyManager

    lateinit var jsonobject: JSONObject

     var producturl:String=""


    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home)
        statusUtility= utilityClass(this)
        statusUtility.StatusBarColor()

        var intent = getIntent()
        if(intent.extras != null){
           producturl = intent.getStringExtra("BarCode")
        }

        call = findViewById(R.id.call)
        email = findViewById(R.id.email)
        share = findViewById(R.id.share)
        webview = findViewById(R.id.webview)
//        rateus = findViewById(R.id.rateus)
        barcode = findViewById(R.id.barcode)
        barcodeProgressBar = findViewById(R.id.progressBar)
        progressBar = findViewById(R.id.progressBar2)
        progressBar.setVisibility(View.GONE)
        barcodeProgressBar.visibility = View.GONE
        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

        CheckPerrmissions()


        sharedPreference= PreferenceManager.getDefaultSharedPreferences(this)

        var getvalue = sharedPreference.getString("NellaiMartDetails","")
        jsonobject = JSONObject(getvalue)


//        webview.getSettings().setBuiltInZoomControls(true)
        webview.setVerticalScrollBarEnabled(false)
        webview.setHorizontalScrollBarEnabled(false)
        webview.getSettings().setDisplayZoomControls(false)
        webview.getSettings().setJavaScriptEnabled(true)

        var websiteUrl:String = jsonobject.getString("websiteUrl")
//        webview.setWebViewClient(WebViewClient())

        webview.setWebViewClient(object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
                barcodeProgressBar.visibility = View.VISIBLE
                view.loadUrl(url)
                return true
            }

            override fun onPageFinished(view: WebView, url: String) {
                barcodeProgressBar.setVisibility(View.GONE)
            }
        })

        if(producturl != ""){
            LoadProduct()
        }
        else
        {
            webview.loadUrl(websiteUrl)
        }


        call.setOnClickListener {

            if(telephonyManager.phoneType != TelephonyManager.PHONE_TYPE_NONE){
                if(isCallPermissionEnabled){
                    callIntent(jsonobject)
                }
                else{
                    CallPermission()
                }
            }
            else{
              Toast.makeText(this,"No Sim available",Toast.LENGTH_SHORT).show()
            }

        }

        email.setOnClickListener {

            isAppInstalledOrNot(this,"com.google.android.gm")
            if(isAppInstalledOrNot(this,"com.google.android.gm") == true){
            val intent = Intent(Intent.ACTION_SENDTO)
            var Email:String = jsonobject.getString("mail")
            Log.d("Email",""+Email)
            intent.data = Uri.parse("mailto:" + Email)
                if (intent.resolveActivity(packageManager) != null) {
                    startActivity(intent)
                }
            }
            else{
                Toast.makeText(this,"You have not installed gmail app",Toast.LENGTH_SHORT).show()
            }


        }

        barcode.setOnClickListener {
            if(isCameraPermissionEnabled){
                navigation()
            }
           else{
                CameraPermission()
            }
        }

//        rateus.setOnClickListener {
//            var androidRateusUrl:String = jsonobject.getString("androidRateusUrl")
//            Log.d("androidRateusUrl",""+androidRateusUrl)
//            val openURL = Intent(Intent.ACTION_VIEW)
//            openURL.data = Uri.parse(androidRateusUrl)
//            startActivity(openURL)
//        }

        share.setOnClickListener {
            //            Toast.makeText(this,"Share",Toast.LENGTH_SHORT).show()
            val shareIntent = Intent()
            shareIntent.action = Intent.ACTION_SEND
            shareIntent.type="text/plain"

            var share:String = jsonobject.getString("share")
            var androidRateusUrl:String = jsonobject.getString("androidRateusUrl")
            Log.d("share",""+share)

            shareIntent.putExtra(Intent.EXTRA_TEXT, share+" "+androidRateusUrl)
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(Intent.createChooser(shareIntent,share+" "+androidRateusUrl))
            }
        }
    }

    private fun LoadProduct() {
        val url = URL("https://s3.amazonaws.com/mobilewebapps/shoppickk.json")
        LoadNellaiMartData().execute(url)    }

    private fun callIntent(jsonobject:JSONObject) {

         var intent: Intent? = Intent(Intent.ACTION_CALL)
        when(Build.VERSION.SDK_INT){
            20->  intent = Intent(Intent.ACTION_DIAL)
            21-> intent = Intent(Intent.ACTION_DIAL)
            22-> intent = Intent(Intent.ACTION_DIAL)
        }

//        intent.setPackage("com.android.server.telecom")
        var number:String = jsonobject.getString("call")
        Log.d("number",""+number)
        intent?.data = Uri.parse("tel:" + number)
        startActivity(intent)


    }

    fun navigation(){
        val intent = Intent(this@homeActivity, ScanActivity::class.java)
        startActivityForResult(intent, ADD_TASK_REQUEST)

    }

    fun CheckPerrmissions(){

        ActivityCompat.requestPermissions(this as Activity,
            arrayOf(Manifest.permission.CAMERA, Manifest.permission.CALL_PHONE),
            3)
    }

    fun CallPermission(){
        if (ActivityCompat.checkSelfPermission(this@homeActivity,
        Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED)
            {
                makeRequest(1)

            }
    }

    fun CameraPermission(){

        if (ActivityCompat.checkSelfPermission(this@homeActivity,
                Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED)
        {
            makeRequest(2)
        }
    }



    fun isAppInstalledOrNot(context: Context, applicationId: String): Boolean {
        //applicationId e.g. com.whatsapp
        try {
            context.getPackageManager().getPackageInfo(applicationId, PackageManager.GET_ACTIVITIES);
            return true;
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }
        return false
    }


//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        if (requestCode == ADD_TASK_REQUEST) {
//            if (resultCode == Activity.RESULT_OK) {
//                val task = data?.getStringExtra(ScanActivity.TASK_DESCRIPTION)
//                val url = URL("https://s3.amazonaws.com/mobilewebapps/shoppickk.json")
//                LoadNellaiMartData().execute(url)
//            }
//        }
//    }



    inner class  LoadNellaiMartData: AsyncTask<URL, Int, String>() {

        private var result: String = ""

        override fun onPreExecute() {
            super.onPreExecute()
            webview.setVisibility(View.INVISIBLE)
            barcodeProgressBar.visibility = View.VISIBLE

        }

        override fun onPostExecute(result: String?) {
            super.onPostExecute(result)
            barcodeProgressBar.visibility = View.GONE
            webview.setVisibility(View.VISIBLE)
            var jsonobject = JSONObject(result)

//            var websiteUrl:String = jsonobject.getString("websiteUrl")
            webview.loadUrl("https://nellai-marts-inc.myshopify.com/collections/rice/products/nellaimarts-seeragasamba-jeerasamba-5lbs")

        }


        override fun doInBackground(vararg params: URL?): String {

            val connect = params[0]?.openConnection() as HttpURLConnection
            connect.readTimeout = 8000
            connect.connectTimeout = 8000
            connect.requestMethod = "GET"
            connect.connect()

            val responseCode: Int = connect.responseCode
            if (responseCode == 200) {
                result = streamToString(connect.inputStream)
            }

            return result
        }

    }

    fun streamToString(inputStream: InputStream): String {

        val bufferReader = BufferedReader(InputStreamReader(inputStream))
        var line: String
        var result = ""

        try {
            do {
                line = bufferReader.readLine()
                if (line != null) {
                    result += line
                }
            } while (line != null)
            inputStream.close()
        } catch (ex: Exception) {

        }
        return result
    }

    override fun onBackPressed() {
        moveTaskToBack(true)
        exitProcess(-1)
    }
    private fun makeRequest(permissonFor:Int) {
        when(permissonFor) {
            1->        ActivityCompat.requestPermissions(this,
                arrayOf(Manifest.permission.CALL_PHONE),
                1)
            2->ActivityCompat.requestPermissions(this,
                arrayOf(Manifest.permission.CAMERA),
                2)
        }


    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
//        Toast.makeText(this,""+permissions.size,Toast.LENGTH_LONG).show()
        if(requestCode == 3){
            if(grantResults[0] == PackageManager.PERMISSION_GRANTED){
                isCameraPermissionEnabled = true
            }
            if(grantResults[1] == PackageManager.PERMISSION_GRANTED){
                isCallPermissionEnabled = true
            }

        }
        if(requestCode == 1){
            if(grantResults[0] == PackageManager.PERMISSION_GRANTED){
                callIntent(jsonobject)
                //isCallPermissionEnabled = true
            }
        }
        if(requestCode == 2){
            if(grantResults[0] == PackageManager.PERMISSION_GRANTED){
                navigation()
                //isCameraPermissionEnabled = true
            }
        }

    }




}


