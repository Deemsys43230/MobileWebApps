package com.deemsysinc.myapplicationsample;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ExpandableListView;
import android.widget.ListAdapter;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class ExpandListActivity extends AppCompatActivity {

    ExpListAdapter listAdapter;
    ExpandableListView expListView;
    List<String> dataHeader;
    HashMap<String, List<String>> dataChild;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_expand_list);
        expListView = findViewById(R.id.expandable_list);

        ListData();
        listAdapter = new ExpListAdapter(this,dataHeader,dataChild);
        expListView.setAdapter(listAdapter);

        expListView.setOnChildClickListener(new ExpandableListView.OnChildClickListener() {
            @Override
            public boolean onChildClick(ExpandableListView parent, View v, int groupPosition, int childPosition, long id) {
                Toast.makeText(ExpandListActivity.this, "Item :"+dataChild.get(dataHeader.get(groupPosition)).get(childPosition), Toast.LENGTH_SHORT).show();
                return false;
            }
        });
    }

    private void ListData() {

        dataHeader = new ArrayList<String>();
        dataChild = new HashMap<String,List<String>>();

        dataHeader.add("Veg");
        dataHeader.add("Nonveg");
        dataHeader.add("Dessert");

        List<String> Veg = new ArrayList<String>();
        Veg.add("Dosa");
        Veg.add("Idli");
        Veg.add("Poori");

        List<String> Nonveg = new ArrayList<String>();
        Nonveg.add("Briyani");
        Nonveg.add("Chicken");
        Nonveg.add("Mutton");

        List<String> Dessert = new ArrayList<String>();
        Dessert.add("Ice cream");
        Dessert.add("Cake");

        dataChild.put(dataHeader.get(0),Veg);
        dataChild.put(dataHeader.get(1),Nonveg);
        dataChild.put(dataHeader.get(2),Dessert);
    }


}
