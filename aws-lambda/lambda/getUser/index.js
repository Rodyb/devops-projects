const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    console.log("🔎 GetUserFunction invoked");
    console.log("Received event:", JSON.stringify(event));

    const userId = event.pathParameters?.id;

    if (!userId) {
        return {
            statusCode: 400,
            body: JSON.stringify({ message: "Missing userId in path" }),
        };
    }

    const result = await db.get({
        TableName: process.env.TABLE_NAME,
        Key: { userId }
    }).promise();

    if (!result.Item) {
        return {
            statusCode: 404,
            body: JSON.stringify({ message: "User not found" }),
        };
    }

    return {
        statusCode: 200,
        body: JSON.stringify(result.Item),
    };
};
