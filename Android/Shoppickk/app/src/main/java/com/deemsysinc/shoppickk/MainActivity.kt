package com.deemsysinc.shoppickk



import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.net.ConnectivityManager
import android.os.AsyncTask
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.preference.PreferenceManager
import android.view.View
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import com.deemsysinc.shoppickk.Utils.NetWorkChangeReciver
import com.deemsysinc.shoppickk.Utils.utilityClass
import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL



@Suppress("DEPRECATION")
class MainActivity :  AppCompatActivity(), NetWorkChangeReciver.ConnectivityReceiverListener  {

    lateinit var progressBar:ProgressBar
    lateinit var loading: TextView
    lateinit var sharedPreference:SharedPreferences
    val url = URL("https://s3.amazonaws.com/mobilewebapps/shoppickk.json")
    lateinit  var statusUtility: utilityClass


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        statusUtility= utilityClass(this)
        statusUtility.StatusBarColor()

        registerReceiver(NetWorkChangeReciver(),
            IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION))

        sharedPreference=PreferenceManager.getDefaultSharedPreferences(this)
        loading = findViewById(R.id.loading)
        progressBar = findViewById(R.id.progressBar)
        progressBar.visibility = View.VISIBLE
        loading.visibility = View.VISIBLE


    }

    private fun showMessage(isConnected: Boolean) {

        if (!isConnected) {
            Toast.makeText(this,"You are offline now.",Toast.LENGTH_SHORT).show()

        } else {
//            Toast.makeText(this,"You are online now",Toast.LENGTH_SHORT).show()
            LoadShoppickkData().execute(url)
        }

    }

    override fun onResume() {
        super.onResume()
        NetWorkChangeReciver.connectivityReceiverListener = this
    }


    override fun onNetworkConnectionChanged(isConnected: Boolean) {
        showMessage(isConnected)
    }


    inner class  LoadShoppickkData: AsyncTask <URL, Int, String>() {

        private var result: String = ""

        override fun onPreExecute() {
            super.onPreExecute()
            progressBar.visibility = View.VISIBLE

        }

        override fun onPostExecute(result: String?) {
            super.onPostExecute(result)
            progressBar.visibility = View.GONE
            loading.visibility = View.GONE
            val editor: SharedPreferences.Editor = sharedPreference.edit()
            editor.putString("ShoppickkDetails", result)
            editor.commit()
            val intent = Intent(this@MainActivity, homeActivity::class.java)
            startActivity(intent)
        }


        override fun doInBackground(vararg params: URL?): String {

            val connect = params[0]?.openConnection() as HttpURLConnection
            connect.readTimeout = 8000
            connect.connectTimeout = 8000
            connect.requestMethod = "GET"
            connect.connect()

            val responseCode: Int = connect.responseCode;
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