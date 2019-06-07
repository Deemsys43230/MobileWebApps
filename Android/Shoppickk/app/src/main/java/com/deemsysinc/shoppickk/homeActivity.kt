package com.deemsysinc.shoppickk


import android.Manifest
import android.app.Activity
import android.content.Context
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.graphics.Typeface
import android.webkit.WebView
import android.widget.TextView
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.preference.PreferenceManager
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import android.telephony.TelephonyManager
import android.util.Log
import android.view.View
import android.webkit.WebViewClient
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.Toast
import com.deemsysinc.shoppickk.Utils.utilityClass
import org.json.JSONObject
import kotlin.system.exitProcess


class homeActivity : AppCompatActivity() {
        lateinit var font: Typeface
        lateinit var call: ImageView
        lateinit var email:ImageView
        lateinit var share:ImageView
        lateinit var webview:WebView
        lateinit var rateus:ImageView
        lateinit var  progressBar:ProgressBar
        lateinit var sharedPreference: SharedPreferences
        lateinit  var statusUtility:utilityClass
        var isCallPermissionEnabled:Boolean=false
        lateinit var jsonobject:JSONObject


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home)
        statusUtility= utilityClass(this)
        statusUtility.StatusBarColor()


        font  = Typeface.createFromAsset(assets, "fontawesome-webfont.ttf")
        call = findViewById(R.id.call)
        email = findViewById(R.id.email)
        share = findViewById(R.id.share)
        webview = findViewById(R.id.webview)
        rateus = findViewById(R.id.rateus)
        progressBar = findViewById(R.id.progressBar2)

        progressBar.visibility = View.VISIBLE

        CheckPerrmissions()

        sharedPreference= PreferenceManager.getDefaultSharedPreferences(this)

        if(sharedPreference.contains("ShoppickkDetails")){

            Log.d("jsonobject data","result data")
        }

        var getvalue = sharedPreference.getString("ShoppickkDetails","")
        jsonobject = JSONObject(getvalue)
        Log.d("jsonobjectdata",""+getvalue)


//        webview.getSettings().setBuiltInZoomControls(true)
        webview.setVerticalScrollBarEnabled(false)
        webview.setHorizontalScrollBarEnabled(false)
        webview.getSettings().setDisplayZoomControls(false)
        webview.getSettings().setJavaScriptEnabled(true)

        var websiteUrl:String = jsonobject.getString("websiteUrl")

        webview.loadUrl(websiteUrl)

        webview.setWebViewClient(object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
                progressBar.setVisibility(View.VISIBLE)
                view.loadUrl(url)
                return true
            }

            override fun onPageFinished(view: WebView, url: String) {
                progressBar.setVisibility(View.GONE)
            }
        })


        call.setOnClickListener {

            if(isCallPermissionEnabled){
                callIntent(jsonobject)
            }
            else
            {
                CallPermission()

            }

        }



        email.setOnClickListener {
            isAppInstalledOrNot(this,"com.google.android.gm")

            if(isAppInstalledOrNot(this,"com.google.android.gm") == true) {
                val intent = Intent(Intent.ACTION_SENDTO)
                var Email: String = jsonobject.getString("mail")
                Log.d("Email", "" + Email)
                intent.data = Uri.parse("mailto:" + Email)
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                    }
            }
        }

        rateus.setOnClickListener {
            val openURL = Intent(android.content.Intent.ACTION_VIEW)
            openURL.data = Uri.parse("https://play.google.com/store/apps/details?id=com.deemsysinc.cyberhealthapp")
            startActivity(openURL)
        }

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

    private fun callIntent(jsonobject:JSONObject) {
        var intent: Intent? = Intent(Intent.ACTION_CALL)
        when(Build.VERSION.SDK_INT){
            20->  intent = Intent(Intent.ACTION_DIAL)
            21-> intent = Intent(Intent.ACTION_DIAL)
            22-> intent = Intent(Intent.ACTION_DIAL)
        }
        var number:String = jsonobject.getString("call")
        Log.d("number",""+number)
        intent?.data = Uri.parse("tel:" + number)

        if (intent?.resolveActivity(packageManager) != null) {
            startActivity(intent)
        }

    }

    fun CheckPerrmissions(){

        ActivityCompat.requestPermissions(this as Activity,
            arrayOf(Manifest.permission.CAMERA, Manifest.permission.CALL_PHONE),
            2)

    }


    private fun setupPermissions() {
        val permission = ContextCompat.checkSelfPermission(this,
            Manifest.permission.CALL_PHONE)

        if (permission != PackageManager.PERMISSION_GRANTED) {
            Log.i("none", "Permission to Call has denied")
            makeRequest()
        }
    }

    fun CallPermission(){
        if (ActivityCompat.checkSelfPermission(this@homeActivity,
                Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED)
        {
            makeRequest()

        }
    }

    private fun makeRequest() {
        ActivityCompat.requestPermissions(this,
            arrayOf(Manifest.permission.CALL_PHONE),
            1)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if(requestCode == 3){
            if(grantResults[0] == PackageManager.PERMISSION_GRANTED){
                isCallPermissionEnabled = true
            }
        }
        if(requestCode == 1){
            if(grantResults[0] == PackageManager.PERMISSION_GRANTED){
                callIntent(jsonobject)
            }
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

    override fun onBackPressed() {
        moveTaskToBack(true)
        exitProcess(-1)
    }




}






