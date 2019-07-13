package com.deemsysinc.myapplicationsample;

import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.TextView;
import android.view.View;

import java.util.List;

public class Listadapter extends RecyclerView.Adapter<Listadapter.MyViewHolder> {

        private List<dataList> rowList;

    public class MyViewHolder extends RecyclerView.ViewHolder {
        public TextView title, gen ,year;

        public MyViewHolder(View view) {
            super(view);
            title = view.findViewById(R.id.title);
            gen = view.findViewById(R.id.gen);
            year = view.findViewById(R.id.year);
        }
    }

    public Listadapter(List<dataList>rowList){
        this.rowList = rowList;
    }

    @NonNull
    @Override
    public MyViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {
        View  itemView = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.list_row,viewGroup,false);
        return new MyViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(@NonNull MyViewHolder myViewHolder, int i) {

        dataList list = rowList.get(i);
        myViewHolder.title.setText(list.getTitle());
        myViewHolder.gen.setText(list.getGendral());
        myViewHolder.year.setText(list.getYear());
    }

    @Override
    public int getItemCount() {
        return rowList.size();
    }


}
