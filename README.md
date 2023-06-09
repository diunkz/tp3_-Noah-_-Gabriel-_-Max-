# ufam-db-tp3

## buildar a imagem

```bash
docker build -t tp3 .
```

## executar dentro da pasta para rodar o contêiner
```bash
docker run -p 5433:5432 -p 8888:8888 -v $(pwd)/notebook/:/app/notebook tp3
docker run -p 5433:5432 -p 8888:8888 -v $(pwd)/datadir/:/app/datadir -v $(pwd)/notebook/:/app/notebook tp3
```

A porta 5432 é do postgres e a 8888 do Jupyter

Para acessar o jupyter, entre na pasta notebook

```bash
cd notebook
```

execute o comando

```bash
jupyter-lab --no-browser --ip=0.0.0.0 --port=8888
```

e acesse normalmente no seu navegador:

http://localhost:8888
