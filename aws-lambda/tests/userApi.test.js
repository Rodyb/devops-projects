const axios = require("axios");

const baseUrl = process.env.API_URL;

describe("User API integration", () => {
    it("should create a user and then retrieve it", async () => {
        const testUser = {
            userId: `test-${Date.now()}`,
            name: "Test User"
        };

        const createRes = await axios.post(`${baseUrl}`, testUser);

        expect(createRes.status).toBe(201);
        expect(createRes.data.message).toBe("User created");
        expect(createRes.data.userId).toBe(testUser.userId);

        const getRes = await axios.get(`${baseUrl}/${testUser.userId}`);

        expect(getRes.status).toBe(200);
        expect(getRes.data).toMatchObject({
            userId: testUser.userId,
            name: testUser.name
        });
    });

    it("should return 404 for nonexistent user", async () => {
        try {
            await axios.get(`${baseUrl}/nonexistent-id`);
        } catch (err) {
            expect(err.response.status).toBe(404);
            expect(err.response.data.message).toMatch(/not found/i);
        }
    });
});
