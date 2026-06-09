import json
import logging
import os
import random
import time
from datetime import datetime

from fastapi import FastAPI, HTTPException, Request
from prometheus_client import Counter, Histogram, make_asgi_app

from opentelemetry import trace
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter


SERVICE_NAME = "student-web-api"
LOG_FILE = "/logs/app.log"


os.makedirs("/logs", exist_ok=True)

logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(message)s",
)

resource = Resource.create(
    {
        "service.name": SERVICE_NAME,
        "service.version": "1.0.0",
        "deployment.environment": "lab",
    }
)

trace_provider = TracerProvider(resource=resource)

otlp_endpoint = os.getenv(
    "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT",
    "http://otel-collector:4317",
)

trace_exporter = OTLPSpanExporter(
    endpoint=otlp_endpoint,
    insecure=True,
)

trace_provider.add_span_processor(
    BatchSpanProcessor(trace_exporter)
)

trace.set_tracer_provider(trace_provider)
tracer = trace.get_tracer(__name__)


app = FastAPI(title="Student Web API Observability Lab")

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["service", "route", "method", "status"],
)

REQUEST_DURATION = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["service", "route", "method"],
    buckets=[0.05, 0.1, 0.2, 0.3, 0.5, 1, 2, 5],
)


def write_log(level: str, message: str, **fields):
    span = trace.get_current_span()
    span_context = span.get_span_context()

    record = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "level": level,
        "service": SERVICE_NAME,
        "message": message,
        "trace_id": format(span_context.trace_id, "032x") if span_context.trace_id else None,
        "span_id": format(span_context.span_id, "016x") if span_context.span_id else None,
        **fields,
    }

    logging.info(json.dumps(record))


@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    route = request.url.path
    method = request.method

    if route.startswith("/metrics"):
        return await call_next(request)

    start = time.time()
    status_code = 500

    try:
        response = await call_next(request)
        status_code = response.status_code
        return response
    except Exception:
        status_code = 500
        raise
    finally:
        duration = time.time() - start

        REQUEST_COUNT.labels(
            service=SERVICE_NAME,
            route=route,
            method=method,
            status=str(status_code),
        ).inc()

        REQUEST_DURATION.labels(
            service=SERVICE_NAME,
            route=route,
            method=method,
        ).observe(duration)

        write_log(
            "info" if status_code < 500 else "error",
            "request completed",
            route=route,
            method=method,
            status=status_code,
            duration_ms=round(duration * 1000, 2),
        )


@app.get("/")
def root():
    return {
        "message": "Observability lab is running",
        "try": ["/fast", "/slow", "/error", "/flaky"],
    }


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/fast")
def fast():
    with tracer.start_as_current_span("fast_business_logic"):
        time.sleep(0.05)
        write_log("info", "fast endpoint completed", route="/fast")
        return {"status": "ok", "type": "fast"}


@app.get("/slow")
def slow():
    with tracer.start_as_current_span("slow_database_query"):
        time.sleep(0.8)
        write_log("info", "slow endpoint completed", route="/slow")
        return {"status": "ok", "type": "slow", "sleep_seconds": 0.8}


@app.get("/error")
def error():
    with tracer.start_as_current_span("failing_business_logic"):
        write_log("error", "simulated internal server error", route="/error")
        raise HTTPException(status_code=500, detail="simulated error")


@app.get("/flaky")
def flaky(fail_rate: float = 0.3):
    with tracer.start_as_current_span("flaky_business_logic"):
        if random.random() < fail_rate:
            write_log("error", "flaky endpoint failed", route="/flaky", fail_rate=fail_rate)
            raise HTTPException(status_code=500, detail="random failure")

        time.sleep(0.1)
        write_log("info", "flaky endpoint succeeded", route="/flaky", fail_rate=fail_rate)
        return {"status": "ok", "type": "flaky", "fail_rate": fail_rate}


metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)

FastAPIInstrumentor.instrument_app(app)
