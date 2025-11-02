import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 1000,
  duration: '1m',
};

export default function () {
  // Make a GET request to the line service target URL
  const response = http.get(`http://localhost:3000/lines/${Math.floor(Math.random() * 10000)}`);

  // Check that the response status is 200 OK and response time is under 500ms
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  // Sleep for 1 second to simulate real-world usage
  sleep(1);
}