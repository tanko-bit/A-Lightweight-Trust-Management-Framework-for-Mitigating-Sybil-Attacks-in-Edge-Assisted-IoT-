FROM python:3.11.8-slim-bookworm

LABEL maintainer="LTMF Authors <tibrahim@stu.csuc.edu.gh>"
LABEL description="Reproducibility container for LTMF: Lightweight Trust Management Framework for Edge IoT"

# Set environment variables for reproducibility
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

# Install system utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    time \
    && rm -rf /var/lib/apt/lists/*

# Install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy codebase
COPY . .

# Set strict 512 MB memory limit via ulimit test script
RUN chmod +x run_experiments.sh

CMD ["./run_experiments.sh"]
