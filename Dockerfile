FROM python:3.12-alpine

ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

RUN adduser -D -u 10001 appuser
USER appuser

EXPOSE 8787
CMD ["python", "app.py"]