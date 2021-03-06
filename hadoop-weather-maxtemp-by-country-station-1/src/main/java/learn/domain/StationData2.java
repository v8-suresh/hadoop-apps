package learn.domain;

import learn.parser.Parseble;
import learn.parser.Parser;
import learn.parser.spi.StationData2Parser;
import org.apache.hadoop.io.FloatWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;

/**
 * Created by suren on 24/10/14.
 */
public class StationData2 implements Parseble {

    private int station;
    private int wban;
    private String stationName;
    private String countryCode;
    private String stateCodeUs;
    private float latitude;
    private float longitude;
    private float elevation;

    public int getStation() {
        return station;
    }

    public void setStation(int station) {
        this.station = station;
    }

    public int getWban() {
        return wban;
    }

    public void setWban(int wban) {
        this.wban = wban;
    }

    public String getStationName() {
        return stationName;
    }

    public void setStationName(String stationName) {
        this.stationName = stationName;
    }

    public String getCountryCode() {
        return countryCode;
    }

    public void setCountryCode(String countryCode) {
        this.countryCode = countryCode;
    }

    public String getStateCodeUs() {
        return stateCodeUs;
    }

    public void setStateCodeUs(String stateCodeUs) {
        this.stateCodeUs = stateCodeUs;
    }

    public float getLatitude() {
        return latitude;
    }

    public void setLatitude(float latitude) {
        this.latitude = latitude;
    }

    public float getLongitude() {
        return longitude;
    }

    public void setLongitude(float longitude) {
        this.longitude = longitude;
    }

    public float getElevation() {
        return elevation;
    }

    public void setElevation(float elevation) {
        this.elevation = elevation;
    }

    public StationData2Writable getStationData2Writable(){
        StationData2Writable writable = new StationData2Writable();
        writable.setStation(new IntWritable(getStation()));
        writable.setWban(new IntWritable(getWban()));
        writable.setStationName(new Text(getStationName()));
        writable.setCountryCode(new Text(getCountryCode()));
        writable.setStateCodeUs(new Text(getStateCodeUs()));
        writable.setLatitude(new FloatWritable(getLatitude()));
        writable.setLongitude(new FloatWritable(getLongitude()));
        writable.setElevation(new FloatWritable(getElevation()));
        return writable;
    }

    @Override
    public Parser<StationData2> getParser() {
        return new StationData2Parser<StationData2>();
    }

    @Override
    public String toString() {
        return "CountryData2{" +
                "station=" + station +
                ", wban=" + wban +
                ", stationName='" + stationName + '\'' +
                ", countryCode='" + countryCode + '\'' +
                ", stateCodeUs='" + stateCodeUs + '\'' +
                ", latitude=" + latitude +
                ", longitude=" + longitude +
                ", elevation=" + elevation +
                '}';
    }
}
