FROM python:3.9-slim-buster
ENV PYTHONUNBUFFERED 1
WORKDIR /app

COPY requirements.txt requirements.txt
COPY app/templates templates
COPY app/static static
RUN python -m pip install --upgrade pip
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Define environment variable for Flask
ENV FLASK_APP=app.py

CMD ["python3", "app/app.py"]