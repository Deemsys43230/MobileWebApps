package com.deemsysinc.nellaimarts

import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.net.ConnectivityManager
import android.os.AsyncTask
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.preference.PreferenceManager
import android.view.View
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import com.deemsysinc.nellaimarts.Utils.NetWorkChangeReciver
import com.deemsysinc.nellaimarts.Utils.utilityClass
import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import android.support.design.widget.Snackbar
import android.util.Log
import kotlinx.android.synthetic.main.activity_home.*
import org.json.JSONArray
import org.json.JSONObject


@Suppress("DEPRECATION")
class MainActivity : AppCompatActivity(), NetWorkChangeReciver.ConnectivityReceiverListener {

    lateinit  var statusUtility:utilityClass
    lateinit var loading: TextView

    lateinit var progressBar: ProgressBar
    lateinit var sharedPreference: SharedPreferences
    val url = URL("https://s3.amazonaws.com/mobilewebapps/nellaimart.json")
//    val url = URL("https://s3.amazonaws.com/mobilewebapps/shoppickk.json")


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        statusUtility= utilityClass(this)
        statusUtility.StatusBarColor()
        registerReceiver(NetWorkChangeReciver(),
            IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)
        )

        sharedPreference= PreferenceManager.getDefaultSharedPreferences(this)
        loading = findViewById(R.id.loading)
        progressBar = findViewById(R.id.progressBar)
        progressBar.visibility = View.VISIBLE
        loading.visibility = View.VISIBLE
    }

    private fun showMessage(isConnected: Boolean) {

        if (!isConnected) {
//            val snack = Snackbar.make(root_layout,"You are offline now",Snackbar.LENGTH_LONG)
//            snack.show()
            Toast.makeText(this,"You are offline now.", Toast.LENGTH_SHORT).show()

        } else {
//            Toast.makeText(this,"You are online now", Toast.LENGTH_SHORT).show()
            LoadNellaiMartData().execute(url)
        }

    }

    override fun onResume() {
        super.onResume()
        NetWorkChangeReciver.connectivityReceiverListener = this
    }


    override fun onNetworkConnectionChanged(isConnected: Boolean) {
        showMessage(isConnected)
    }


    inner class  LoadNellaiMartData: AsyncTask<URL, Int, String>() {

        private var result: String = ""

        override fun onPreExecute() {
            super.onPreExecute()
            progressBar.visibility = View.VISIBLE

        }

        override fun onPostExecute(result: String?) {
            super.onPostExecute(result)

            var resArray=JSONArray(result)
            Log.d("ResponseResult",""+ resArray[0])
            progressBar.visibility = View.GONE
            loading.visibility = View.GONE
            val editor: SharedPreferences.Editor = sharedPreference.edit()
            editor.commit()
            editor.putString("NellaiMartDetails", resArray[0].toString())
//             for(k in 0..resArray.length()-1)
//             {
//                 var jsonObject:JSONObject
//                 jsonObject=resArray.getJSONObject(k)
//                 Log.d("PrintResult",""+jsonObject.getString("location"))
//                 items.add(jsonObject.getString("location"))
//             }
            editor.putString("LocationList",result)
            editor.commit()
            val intent = Intent(this@MainActivity, homeActivity::class.java)
            startActivity(intent)
        }


        override fun doInBackground(vararg params: URL?): String {

            val connect = params[0]?.openConnection() as HttpURLConnection
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
}
