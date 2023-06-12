FROM debian:11.7-slim

ENV DEBIAN_FRONTEND=noninteractive
# colocar o mesmo usuário do linux que executará o docker
ARG USERNAME=diunkz
# escolha uma senha, deixei s como padrão
ARG PASSWORD=s

# Cria um novo usuário com o mesmo nome do linux
RUN useradd -ms /bin/bash $USERNAME

# Concede permissões de root ao usuário e define a senha escolhida acima para ele
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && echo "$USERNAME:$PASSWORD" | chpasswd

# Etapa de instalação e configuração inicial
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    python3 \
    python3-dev \
    python3-pip \
    wget \
    nano \
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

# criação da pasta tables, onde ficará o script movie.sql
RUN mkdir tables
WORKDIR /app/tables
RUN wget "https://drive.google.com/uc?export=download&id=1W6wovSsVu4B0OIo_tsSBBHi8WRKQqnat" -O movie.sql

# Download e instalação do tpch-dbgen
WORKDIR /app/tpch-pgsql
RUN wget -q https://github.com/electrum/tpch-dbgen/archive/32f1c1b92d1664dba542e927d23d86ffa57aa253.zip -O tpch-dbgen.zip \
    && unzip -q tpch-dbgen.zip \
    && mv tpch-dbgen-32f1c1b92d1664dba542e927d23d86ffa57aa253 tpch-dbgen \
    && rm tpch-dbgen.zip \
    && chmod -R ugo+w /app

# alterando o método de autenticação de peer para md5
RUN sed -i 's/local   all             all                                     peer/local   all             all                                     md5/' /etc/postgresql/13/main/pg_hba.conf

# Configuração do PostgreSQL
RUN echo 'postgres:postgres' | chpasswd
WORKDIR /app
USER postgres
RUN pg_ctlcluster 13 main start \
    && createuser tpch \
    && createuser aluno \
    && createdb tpchdb \
    && createdb banco \
    && psql -c "ALTER USER tpch PASSWORD 'pass';" \
    && psql -c "ALTER USER aluno PASSWORD 'senhaaluno';" \
    && psql -c "GRANT ALL PRIVILEGES ON DATABASE tpchdb TO tpch;" \
    && psql -c "GRANT ALL PRIVILEGES ON DATABASE banco TO aluno;" \
    && pg_ctlcluster 13 main stop


# Comando para iniciar o PostgreSQL. O segundo comando garante que o contêiner fique em execução.
CMD pg_ctlcluster 13 main start && tail -f /dev/null
