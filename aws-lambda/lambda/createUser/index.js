const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    console.log("👤 CreateUserFunction invoked");
    console.log("Received event:", JSON.stringify(event));

    const body = JSON.parse(event.body || "{}");
    const { userId, name } = body;

    if (!userId || !name) {
        return {
            statusCode: 400,
            body: JSON.stringify({ message: "Missing userId or name" }),
        };
    }

    await db.put({
        TableName: process.env.TABLE_NAME,
        Item: { userId, name, createdAt: new Date().toISOString() }
    }).promise();

    return {
        statusCode: 201,
        body: JSON.stringify({ message: "User created", userId }),
    };
};
