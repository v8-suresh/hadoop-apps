import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;

/**
 * Created by 743522 on 23-10-2014.
 */
public class WeatherMapper extends Mapper<LongWritable, Text, Text, WeatherDataWritable> {


//    private int groupByFieldIdx;
//    private String maxOrMin = "";
//    private int valFieldIdx;
//
//    @Override
//    protected void setup(Context context) throws IOException, InterruptedException {
//        Configuration config = context.getConfiguration();
//        groupByFieldIdx = config.getInt("app.groupbyidx", 6);
//        valFieldIdx = config.getInt("app.valfieldidx", 1);
//        maxOrMin = config.get("app.minmax", "MAX");
//        super.setup(context);
//    }

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        WeatherDataWritable datum = WeatherDataWritable.getWeatherData(value);

        //  If all the weather data is wrong - skip that record.
        if((datum.getTemp().get() == WeatherDataParser.INVALID_TEMP) &&
                (datum.getWindspeed().get() == WeatherDataParser.INVALID_WINDSPEED) &&
                (datum.getVisibility().get() == WeatherDataParser.INVALID_VISIBILITY) &&
                (datum.getPercipitation().get() == WeatherDataParser.INVALID_PERCIPITATION)){
            // Increment Counter for All Wrong Data
            context.getCounter(InvalidData.ALL_MISSING).increment(1);
            return;
        }

        context.write(new Text(datum.getYear().toString()), datum);

    }
}
