import http from 'k6/http';
import { check, sleep } from 'k6';

export default function () {
    const baseUrl = 'http://host.docker.internal:8000';

    const payload = JSON.stringify({
        name: "TestItem",
        description: "Created via k6"
    });

    const headers = { 'Content-Type': 'application/json' };

    const createRes = http.post(`${baseUrl}/items`, payload, { headers });

    check(createRes, {
        'created item successfully': (r) => r.status === 200,
    });

    const itemId = createRes.json().id;
    console.log(`Created item with ID: ${itemId}`);

    const deleteRes = http.del(`${baseUrl}/items/${itemId}`);

    check(deleteRes, {
        'deleted item successfully': (r) => r.status === 200,
    });

    sleep(1);
}
