const { GenericContainer, Wait } = require('testcontainers');
const axios = require('axios');

describe('App Integration Tests', () => {
  let container;
  let containerUrl;

  beforeAll(async () => {
    console.log('Building image from Dockerfile...');

    // Build the image from Dockerfile, then configure the container
    const builtContainer = await GenericContainer.fromDockerfile('.').build();

    container = await builtContainer
      .withExposedPorts(3000)
      .withWaitStrategy(Wait.forLogMessage(/Server listening on port \d+/))
      .start();

    // Get the mapped port
    const host = container.getHost();
    const mappedPort = container.getMappedPort(3000);
    containerUrl = `http://${host}:${mappedPort}`;

    console.log(`Container started at ${containerUrl}`);
  }, 120000); // 120 second timeout for container startup

  afterAll(async () => {
    if (container) {
      await container.stop();
    }
  });

  it('should respond with "Hello World!" on GET /', async () => {
    try {
      console.log(`Making request to: ${containerUrl}`);
      const response = await axios.get(containerUrl);

      console.log(`Response status: ${response.status}`);
      console.log(`Response data: "${response.data}"`);

      expect(response.status).toBe(200);
      expect(response.data).toBe('Hello World!');
    } catch (error) {
      console.error('Test request failed:', error.message);
      throw error;
    }
  });
});