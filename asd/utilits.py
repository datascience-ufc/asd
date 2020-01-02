import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.utils.multiclass import unique_labels
from asd import metrics

import numpy as np


def plot_confusion_matrix(y_test, result, cmap=plt.cm.Blues):
    # Confusion matrix
    cm = confusion_matrix(y_test, result)
    classe = unique_labels(y_test, result)
    fig, ax = plt.subplots()
    im = ax.imshow(cm, interpolation="nearest", cmap=cmap)
    ax.figure.colorbar(im, ax=ax)
    # We want to show all ticks...
    ax.set(
        xticks=np.arange(cm.shape[1]),
        yticks=np.arange(cm.shape[0]),
        # ... and label them with the respective list entries
        xticklabels=classe,
        yticklabels=classe,
        title="Matriz de confusão",
        ylabel="Rótulo real",
        xlabel="Rótulo previsto",
    )

    # Rotate the tick labels and set their alignment.
    plt.setp(
        ax.get_xticklabels(),
        rotation=45,
        ha="right",
        rotation_mode="anchor"
    )

    # Loop over data dimensions and create text annotations.
    thresh = cm.max() / 2.0
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            ax.text(
                j,
                i,
                format(cm[i, j]),
                ha="center",
                va="center",
                color="white" if cm[i, j] > thresh else "black",
            )
    fig.tight_layout()
    return ax


def learning_curve(model, name_model, X, Y, scoring, train_data_size):
    """
    Function responsible for creating a learning curve of a model.
    ---------------------------------------
    Input:
        model -> Parameter responsible for receiving the model to be tested.
                 Note: It is important to note that seram uses only models
                 from the Sklearn library. (For now!!!!)
        name_model -> Parameter that receives or Name of the model to be
                      displayed in the graph.
        X -> Dependent Variable.
        Y -> Independent Variable.
        scoring -> Type of metric used for graph construction.
                   Currently only supported:
                   'precision', 'precision', 'recall' and 'f1'.
        train_data_size -> Size of training data.
    ---------------------------------------
    Output:
        The output is a plot of learning curve graphs.
    """

    resultTrain = []
    resultValid = []
    X_train, X_valid, Y_train, Y_valid = train_test_split(
        X, Y, train_size=train_data_size, random_state=42
    )
    Size = np.linspace(0.05, 1.0, 50).tolist()

    for size in Size:
        X_trainTemp = X_train.iloc[: int(X.shape[0] * size), :]
        Y_trainTemp = Y_train.iloc[: int(X.shape[0] * size)]
        aux = model.fit(X_trainTemp, Y_trainTemp)
        rstTreino = aux.predict(X_trainTemp)
        rstValid = aux.predict(X_valid)
        resultTrain.append(
            metrics.classification_report(Y_trainTemp, rstTreino)[scoring]
        )
        resultValid.append(
            metrics.classification_report(Y_valid, rstValid)[scoring]
        )

    plt.plot(
        Size,
        resultTrain,
        "--",
        color="#111111",
        label="Desempenho Treino"
    )
    plt.plot(
        Size,
        resultValid,
        color="#111111",
        label="Desempenho Validação"
    )

    plt.title("Curva de Aprendizagem - Modelo {}".format(name_model))
    plt.xlabel("Tamanho dos Dados de Treino(%)"), plt.ylabel(
        "{} Score".format(scoring)
    ), plt.legend(loc="best")
    plt.tight_layout()
    plt.show()
