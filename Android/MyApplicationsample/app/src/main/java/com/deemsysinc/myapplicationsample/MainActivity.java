package com.deemsysinc.myapplicationsample;

import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.MotionEvent;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private List<dataList> rowList = new ArrayList<>();
    private RecyclerView recyclerView;
    private Listadapter listadapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        recyclerView = findViewById(R.id.recycle_view);
        listadapter = new Listadapter(rowList);
        recyclerView.setHasFixedSize(true);
        RecyclerView.LayoutManager rlayoutManager = new LinearLayoutManager(getApplicationContext());
        recyclerView.setLayoutManager(rlayoutManager);
        recyclerView.addItemDecoration(new DividerItemDecoration(this, LinearLayoutManager.VERTICAL));
        recyclerView.setItemAnimator(new DefaultItemAnimator());
        recyclerView.setAdapter(listadapter);

        recyclerView.addOnItemTouchListener(new RecyclerTouchListener(getApplicationContext(),recyclerView, new RecyclerTouchListener.ClickListener(){

            @Override
            public void onClick(View view, int position) {

                dataList list = rowList.get(position);
                Toast.makeText(MainActivity.this,"Selected Item :"+position,Toast.LENGTH_SHORT).show();

            }

            @Override
            public void onLongClick(View view, int position) {

            }
        }));

        listData();
    }

    private void listData() {

        dataList list = new dataList ("A2B Restaurant","Multi cuisine","1996");
        rowList.add(list);

        list = new dataList("Bubba Gump Shrimp Co","Seafood restaurant","1997");
        rowList.add(list);

        list = new dataList("ITC","Multi cuisine","1998");
        rowList.add(list);

        list = new dataList("Barbeque","Fast food restaurant","1999");
        rowList.add(list);

        list = new dataList("Buffalo wild wings","Chicken wings restaurant","2000");
        rowList.add(list);

        list = new dataList("Chick-Fil-A","Fast food restaurant","2001");
        rowList.add(list);

        list = new dataList("Crave","Eclectic restaurant","2002");
        rowList.add(list);


        listadapter.notifyDataSetChanged();
    }

}
