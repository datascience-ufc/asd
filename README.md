# [`asd`]
> Simple project description.

Este é um modelo de classificação binário que busca diagnosticar a
partir características comportamentais se uma criança possuí autismo.

## Autores

| Role           | Responsibility   | Full name          | e-mail                         |
| -----          | ---------------- | -----------        | ---------                      |
| Data Scientist | Author           | [`Manoel Vilela`]  | [`manoel_vilela@engineer.com`] |
| Data Scientist | Author           | [`Denilson Gomes`] | [`denilsongomes@alu.ufc.br`] |
| Data Scientist | Author           | [`Matheus Frota`]  | [`matheusfrota1234@gmail.com`] |


## Usage
> Describe how to reproduce your model

Usage is standardized across models. There are two main things you need to know, the development workflow and the Makefile commands.

Both are made super simple to work with Git and Docker while versioning experiments and workspace.

All you'll need to have setup is Docker and Git, which you probably already have. If you don't, feel free to ask for help.

Makefile commands can be accessed using `make help`.


Make sure that **docker** is installed and you have access to S3.

Clone the project from the analytics Models repo.
```
git clone ssh://git@github.com:datascience-ufc/asd.git
cd asd
```

Set the ssh auth variables:
```bash
eval $(ssh-agent)
ssh-add ~/.ssh/your-secret-key
```

Load cloud data & run the project
```bash
make load VERSION=X.Y.Z # load data + models
make run # generate a new model
```

After that, if you want test the IRIS dataset you can predict the
class for new labels using for instance the `workspace/data/test.csv`:

``` bash
make predict INPUT=workspace/data/test.csv
```

You access your workspace in the file `predict/output.csv`.

#### Folder structure
>Explain you folder strucure

* [docs](./docs): contains documentation of the project
* [analysis](./analysis/): contains notebooks of data and modeling experimentation.
* [tests](./tests/): contains files used for unit tests.
* [asd](./asd/): main Python package with source of the model.
