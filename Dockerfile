# -- Stage 1: Build ------------------------------------------------
FROM python:3.12-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# -- Stage 2: Runtime ----------------------------------------------
FROM python:3.12-slim

# Run as non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app
COPY --from=builder /install /usr/local
COPY app.py .

# Set default version; overridden at build time
ARG APP_VERSION=0.0.0-local
ENV APP_VERSION=${APP_VERSION}
ENV PORT=5000

USER appuser
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

CMD ["python", "app.py"]
