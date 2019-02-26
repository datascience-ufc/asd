import numpy as np


# Coeficiente de correlação Phi
def corr_phi(x, y):
    """Calcula a correção de phi entre x e y, sendo x e y arrays"""
    # Dimensão da matriz
    d = (2, 2)

    # Matriz dos fatores
    m = np.zeros(d)

    # Matriz da soma dos fatores
    n = np.zeros(d)

    # Construção da tabela
    for i, j in zip(x, y):
        if (i, j) == (0, 0):
            m[0][0] += 1
        elif (i, j) == (1, 1):
            m[1][1] += 1
        elif (i, j) == (1, 0):
            m[1][0] += 1
        elif (i, j) == (0, 1):
            m[0][1] += 1

    # Soma dos fatores
    n[1][0] = m[1][1] + m[1][0]
    n[0][0] = m[0][1] + m[0][0]
    n[1][1] = m[1][1] + m[0][1]
    n[0][1] = m[1][0] + m[0][0]

    # Formulando a equação
    term1 = (m[1][1] * m[0][0]) - (m[1][0] * m[0][1])
    term2 = np.sqrt(n[1][0] * n[0][0] * n[0][1] * n[1][1])
    return term1 / term2


def corr_pearson(x, y):
    """Calcula correlação de x e y baseado no método de Pearson"""
    # Média das variáveis
    x_m = np.mean(np.array(x))
    y_m = np.mean(np.array(y))

    # Diferença entre cada amostra e a média
    d1 = np.array(x) - x_m
    d2 = np.array(y) - y_m

    # Termos da expressão
    term1 = np.sum(d1 * d2)
    term2 = np.sqrt(np.sum(d1 ** 2) * np.sum(d2 ** 2))
    return term1 / term2
