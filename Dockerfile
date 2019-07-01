FROM ubuntu:18.04
RUN apt-get update && apt-get install -y python-pip
RUN pip install pysam
RUN pip install numpy
COPY Statistics.py /Statistics.py
CMD ["python", "Statistics.py"]
