package demo.lambda.com;

import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClient;
import com.amazonaws.services.dynamodbv2.model.AttributeValue;
import com.amazonaws.services.dynamodbv2.model.UpdateItemRequest;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.DynamodbEvent;
import com.amazonaws.services.lambda.runtime.events.DynamodbEvent.DynamodbStreamRecord;

import java.util.List;
import java.util.Map;

public class Handler implements RequestHandler<DynamodbEvent, String> {

    @Override
    public String handleRequest(DynamodbEvent dynamodbEvent, Context context) {
        List<DynamodbStreamRecord> records = dynamodbEvent.getRecords();
        Map<String, AttributeValue> newImage;
        AmazonDynamoDB dest = AmazonDynamoDBClient.builder()
                .withRegion("eu-west-1")
                .build();
        for (DynamodbStreamRecord record : records) {
            newImage = record.getDynamodb().getNewImage();
            dest.putItem("destdemotable", newImage);

        }
        return "Changes applied";

    }
}
