import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    vus: 100,
    duration: '15s',
};

export default function () {
    const url = 'http://flask-app:5000/employees';

    const response = http.get(url);

    check(response, {
        'status is 200': (r) => r.status === 200,
    });

    sleep(1);
}
