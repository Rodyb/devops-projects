const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();

exports.handler = async () => {
    try {
        const data = await db.scan({
            TableName: process.env.TABLE_NAME
        }).promise();

        return {
            statusCode: 200,
            body: JSON.stringify(data.Items)
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Failed to retrieve users", error })
        };
    }
};
