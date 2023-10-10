const express = require("express");
const Redis = require("ioredis");
const { NodeTracerProvider } = require('@opentelemetry/node');
const { SimpleSpanProcessor } = require('@opentelemetry/tracing');
const { JaegerExporter } = require('@opentelemetry/exporter-jaeger');

const app = express();

// Create a Redis client
const redisClient = new Redis({
  host: process.env.REDIS_HOST, // Replace with the name of the Redis service
  port: 6379, // Replace with the Redis port if it's different
  password: process.env.REDIS_PASS, // Replace with your Redis password
  // When using Istio, TLS is already provided by the envoys. We remove it so it doesn't cause any conflicts.
  // tls: {}, // Password protected AWS ElastiCache clusters require TLS encryption. 
});

// Create an OpenTelemetry TracerProvider and set the Jaeger exporter
const provider = new NodeTracerProvider();
const exporter = new JaegerExporter({
  serviceName: 'express-redis-app', // Replace with your service name
  host: 'jaeger-agent', // Replace with the hostname of your Jaeger agent
  port: 6831, // Replace with the port of your Jaeger agent
});
provider.addSpanProcessor(new SimpleSpanProcessor(exporter));
provider.register();

// Custom middleware to log incoming requests and create spans
app.use((req, res, next) => {
  const tracer = provider.getTracer('express-redis-app-tracer');
  const span = tracer.startSpan(`Received ${req.method} request at: ${req.url}`);
  span.setAttribute('http.method', req.method);
  span.setAttribute('http.url', req.url);
  req.span = span; // Attach the span to the request object
  next();
});

// Retrieve the visitor count from Redis
async function getAndIncrementVisitorCount() {
  try {
    const count = await redisClient.incr("visitor_count");
    return count;
  } catch (error) {
    console.error("Error retrieving visitor count:", error);
    throw error;
  }
}

// API endpoint to retrieve visitor count
app.get("/", async (req, res) => {
  try {
    const visitorCount = await getAndIncrementVisitorCount();
    req.span.end(); // End the span when the operation is complete
    res.json({ count: visitorCount });
  } catch (error) {
    req.span.end(); // End the span in case of an error
    res.status(500).json({ error: "Failed to retrieve visitor count" });
  }
});

// Start the server
const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
