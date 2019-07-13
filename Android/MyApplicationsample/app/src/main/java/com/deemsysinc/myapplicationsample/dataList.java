package com.deemsysinc.myapplicationsample;

public class dataList {

    private String title, gendral , year;

    public dataList(String title, String gendral, String year) {
        this.title = title;
        this.gendral = gendral;
        this.year = year;
    }


    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getGendral() {
        return gendral;
    }

    public void setGendral(String gendral) {
        this.gendral = gendral;
    }

    public String getYear() {
        return year;
    }

    public void setYear(String year) {
        this.year = year;
    }


}
