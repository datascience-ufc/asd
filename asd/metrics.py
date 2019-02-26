# Importando biblioteca
import numpy as np

# Coeficiente de correlação Phi
def corr_phi(x,y):
    n00,n01,n10,n11 = (0,0,0,0)
    # Construção da tabela
    for i,j in zip(x,y):
        if i == j:
            if i == 0:
                n00+=1
            elif j == 1:
                n11+=1
        elif i != j:
            if i == 1 and j == 0:
                n10+=1
            elif i == 0 and j == 1:
                n01+=1
    n1o = n11 + n10
    n0o = n01 + n00
    no1 = n11 + n01
    no0 = n10 + n00
    # Formulando a equação
    term1 = n11*n00 - n10*n01
    term2 = np.sqrt(n1o*n0o*no0*no1)
    return term1/term2

# Coeficiente de correlação de Pearson
def corr_pearson(x,y):
    x_m = np.mean(np.array(x))
    y_m = np.mean(np.array(y))
    d1 = np.array(x) - x_m
    d2 = np.array(y) - y_m
    term1 = np.sum(d1*d2)
    term2 = np.sqrt(np.sum(d1**2)*np.sum(d2**2))
    return term1/term2