FROM python:3.7-alpine

WORKDIR /app

COPY requirements.txt .

RUN apk add --no-cache gcc musl-dev python3-dev && \
    pip install --no-cache-dir -r requirements.txt && \
    apk del gcc musl-dev python3-dev

COPY . .

CMD ["python", "main.py"]
