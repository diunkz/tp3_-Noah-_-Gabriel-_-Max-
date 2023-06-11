FROM debian:11.7-slim

ENV DEBIAN_FRONTEND=noninteractive
ARG USERNAME=diunkz

# Cria um novo usuário chamado "diunkz", id 1000 (o mesmo user e id da minha máquina)
RUN useradd -ms /bin/bash $USERNAME

# Concede permissões de root ao usuário "diunkz" e define a senha 's' para ele
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && echo "$USERNAME:s" | chpasswd

# Etapa de instalação e configuração inicial
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nano \
    python3 \
    python3-dev \
    python3-pip \
    wget \
    unzip \
    postgresql-13 \
    fdisk \
    hdparm \
    smartmontools \
    && echo 'root:123' | chpasswd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Etapa que move todos os arquivos da pasta para a pasta app do contêiner
WORKDIR /app
COPY . /app

# Etapa de configuração do Python e instalação de dependências
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir -r requirements.txt \
    && apt-get autoremove -y

# Download e instalação do tpch-dbgen
WORKDIR /app/tpch-pgsql
RUN wget -q https://github.com/electrum/tpch-dbgen/archive/32f1c1b92d1664dba542e927d23d86ffa57aa253.zip -O tpch-dbgen.zip \
    && unzip -q tpch-dbgen.zip \
    && mv tpch-dbgen-32f1c1b92d1664dba542e927d23d86ffa57aa253 tpch-dbgen \
    && rm tpch-dbgen.zip \
    && chmod -R ugo+w /app

RUN sed -i 's/local   all             all                                     peer/local   all             all                                     md5/' /etc/postgresql/13/main/pg_hba.conf

# Configuração do PostgreSQL
WORKDIR /app
USER postgres
RUN pg_ctlcluster 13 main start \
    && createuser tpch \
    && createdb tpchdb \
    && psql -c "ALTER USER tpch PASSWORD 'pass';" \
    && psql -c "GRANT ALL PRIVILEGES ON DATABASE tpchdb TO tpch;" \
    && pg_ctlcluster 13 main stop

# Comando padrão para iniciar o PostgreSQL e manter o contêiner em execução
CMD pg_ctlcluster 13 main start && tail -f /dev/null
