FROM python:3.11

# AWS Lambdaランタイムインターフェースエミュレータのinstall
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie
COPY entry.sh "/entry.sh"
RUN chmod 755 /usr/bin/aws-lambda-rie /entry.sh

# 実行ファイルをコンテナ内に配置
ARG APP_DIR="/var/task/"
WORKDIR ${APP_DIR}
COPY pict_diff.py ${APP_DIR}

COPY requirements.txt .
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install libgl1-mesa-dev
RUN pip3 install --upgrade pip && pip3 install -r ./requirements.txt

ENTRYPOINT [ "/bin/bash", "/entry.sh" ]
CMD ["pict_diff.lambda_handler"]