package com.deemsysinc.nellaimarts.Utils


import android.content.Intent
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.util.Log
import com.deemsysinc.nellaimarts.HomeActivity
import com.google.zxing.Result
import me.dm7.barcodescanner.zxing.ZXingScannerView



open class ScanActivity:AppCompatActivity(), ZXingScannerView.ResultHandler  {

    private var mScannerView: ZXingScannerView? = null

    public override fun onCreate(state: Bundle?) {
        super.onCreate(state)
        mScannerView = ZXingScannerView(this)
        setContentView(mScannerView)
    }

    companion object {
        val TASK_DESCRIPTION = "task"
    }

    public override fun onResume() {
        super.onResume()
        mScannerView!!.setResultHandler(this)
        mScannerView!!.startCamera()
    }

    public override fun onPause() {
        super.onPause()
        mScannerView!!.stopCamera()
    }

    override fun handleResult(rawResult: Result) {
//        SplashActivity.tvresult!!.setText(rawResult.text)
        Log.d("BarCode Result",""+rawResult)

//        onBackPressed()
        var BarCode = rawResult.toString()
        if(!BarCode.isEmpty()){
            var intent = Intent(this@ScanActivity, HomeActivity::class.java)
            intent.putExtra("BarCode",BarCode)
            startActivity(intent)
        }

//        if (!BarCode.isEmpty()) {
//            val result = Intent()
//            result.putExtra(TASK_DESCRIPTION, BarCode)
//            setResult(Activity.RESULT_OK, result)
//        }
//        else {
//            setResult(Activity.RESULT_CANCELED)
//        }

//        finish()

    }

}