# **Trabalho 3 - Banco de Dados**

### **Alunos:**
- Noah Diunkz
- Max Souza
- Gabriel Pacheco



# Passos para executar o trabalho:
## 1 - clonar o repositório;
## 2 - entrar na pasta clonada;
## 3 - dentro da pasta, buildar a imagem:

```bash
docker build -t tp3 .
```
## ao finalizar, executar dentro da pasta o comando abaixo:
```bash
docker run -p 5433:5432 -p 8888:8888 -v $(pwd)/notebook/:/app/notebook tp3
```

## 4 - Para acessar o jupyter, entre no contêiner, mude o usuário para o informado no dockerfile e acesse a pasta notebook (app/notebook);

```bash
su usuário
cd notebook
```

## 5 - execute o comando:

```bash
jupyter-lab --no-browser --ip=0.0.0.0 --port=8888
```

com um dos links que deve aparecer no log, será possível acessar o jupyter. Feito isso, será possível realizar mudanças e execuções no notebook.